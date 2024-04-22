#include "azureStorage.hpp"
#include <azure/core/exception.hpp>

#include <sstream>
#include <typeinfo>

namespace ObjStorageFdw
{
    using namespace Azure::Storage::Blobs;

    std::shared_ptr<AzureStorage> AzureStorage::GetInstance(unsigned int id)
    {
        if (Storage::instancePool.find(id) == Storage::instancePool.end())
        {
            Storage::instancePool.insert(std::make_pair(id, std::make_shared<AzureStorage>(id)));
        }
        else if (!std::dynamic_pointer_cast<AzureStorage>(Storage::instancePool.at(id)))
        {
            throw std::runtime_error("exist Storage instance but different type");
        }

        return std::dynamic_pointer_cast<AzureStorage>(Storage::instancePool.at(id));
    }

    AzureStorage::AzureStorage(unsigned int id)
    : Storage(id),
    containerName(std::string()),
    pathPrefix(std::string()),
    createContainerIfNotExists(false),
    containerClient(Azure::Storage::Blobs::BlobContainerClient::CreateFromConnectionString("", "")),
    stop(false)
    {
        return;
    }

    AzureStorage::~AzureStorage()
    {
        this->finalize();
    }

    int AzureStorage::initialize(const std::string& accountName, const  std::string& accountKey, const  std::string& blobEndpoint, const bool& createContainerIfNotExists)
    {
        std::lock_guard<std::recursive_mutex> lk(this->mutexSdk);
        std::string strConnectionString;

        if (this->initialized)
        {
            // already initialized
            return -1;
        }

        strConnectionString = "DefaultEndpointsProtocol=";
        strConnectionString += (blobEndpoint.find("https")==0)?"https":"http";
        strConnectionString += ";AccountName=";
        strConnectionString += accountName;
        strConnectionString += ";AccountKey=";
        strConnectionString += accountKey;
        strConnectionString += ";BlobEndpoint=";
        strConnectionString += blobEndpoint;
        strConnectionString += ";";

        this->connectionString = strConnectionString;
        this->createContainerIfNotExists = createContainerIfNotExists;

        this->containerClient = BlobContainerClient::CreateFromConnectionString(connectionString, containerName);

        this->finalize();
        this->stop = false;
        for (int i = 0; i < Storage::maxConcurrent; i++)
        {
            this->downloadWorkers.push_back(std::thread([this]
            {
                std::shared_ptr<StorageItem> downloadItem;

                while (true)
                {
                    {
                        std::unique_lock<std::recursive_mutex> lock(this->mutexDownloadQueue);

                        while (!this->stop && this->downloadTasks.empty())
                        {
                            this->condWorkers.wait(lock);
                        }

                        if (this->stop)
                        {
                            return;
                        }

                        downloadItem = this->downloadTasks.front();
                        this->downloadTasks.pop();
                    }

                    // download
                    std::vector<uint8_t> buffer;
                    std::size_t offset = 0;

                    if (!this->containerName.empty())
                    {
                        offset += this->containerName.length() + 1;
                    }

                    auto path = downloadItem->getPath();
                    path.erase(0, offset);
                    auto blockBlobClient =  this->containerClient.GetBlockBlobClient(path);
                    {
                        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
                        downloadItem->startDownload();
                        std::lock_guard<std::recursive_mutex> lkClass(Storage::mutexClassMembers);
                        Storage::inProgress++;
                    }

                    try
                    {
                        auto blobProperties = blockBlobClient.GetProperties();
                        buffer.resize(static_cast<size_t>(blobProperties.Value.BlobSize));
                        auto response = blockBlobClient.DownloadTo(buffer.data(), buffer.size());

                        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
                        downloadItem->setRawData(&buffer[0], buffer.size());
                        downloadItem->completeDownload(true);
                    }
                    catch (Azure::Core::RequestFailedException &e)
                    {
                        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
                        downloadItem->completeDownload(false, e.what(), e.StatusCode == Azure::Core::Http::HttpStatusCode::NotFound);
                    }
                    catch (std::exception &e)
                    {
                        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
                        downloadItem->completeDownload(false, e.what());
                    }

                    /* Hold the lock */
                    std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
                    std::lock_guard<std::recursive_mutex> lkClass(Storage::mutexClassMembers);
                    Storage::inProgress--;
                    this->completeItems.push_back(downloadItem);
                    this->condInstanceMembers.notify_all();
                }
            }));
        }

        this->initialized = true;
        return 0;
    }

    void AzureStorage::finalize()
    {
        this->stop = true;
        this->condWorkers.notify_all();
        for (auto& item: this->downloadWorkers)
        {
            item.join();
        }
        this->downloadWorkers.clear();

        // 既存のファイル一覧は消す。
        // 進行中のダウンロードは続いてしまうが無視される事になるからよし。
        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
        this->completeItems.clear();
        this->items.clear();

        /* clean target object information */
        this->containerName.clear();
        this->pathPrefix.clear();

        return;
    }

    void AzureStorage::setCallback(const DownloadResult& callback)
    {
        return;
    }

    void AzureStorage::setDirPath(const std::string& path)
    {
        // 既存のファイル一覧は消す。
        // 進行中のダウンロードは続いてしまうが無視される事になるからよし。
        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
        this->completeItems.clear();
        this->items.clear();

        std::size_t pos;
        if ((pos=path.find("/")) != std::string::npos)
        {
            this->containerName = path.substr(0, pos);
            this->pathPrefix = path.substr(pos+1);
        }
        else
        {
            this->containerName = path;
            this->pathPrefix.clear();
        }
        this->containerClient = BlobContainerClient::CreateFromConnectionString(connectionString, containerName);
        if (this->createContainerIfNotExists)
        {
            this->containerClient.CreateIfNotExists();
        }
    }

    void AzureStorage::setFilePath(const std::string& path)
    {
        // 既存のファイル一覧は消す。
        // 進行中のダウンロードは続いてしまうが無視される事になるからよし。
        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
        this->completeItems.clear();
        this->items.clear();

        // ファイルの実在確認はどうするか?
        std::size_t pos;
        if ((pos=path.find("/")) != std::string::npos)
        {
            this->containerName = path.substr(0, pos);
            this->pathPrefix.clear();
            this->items.push_back(std::make_shared<StorageItem>(this->containerName + "/" + path.substr(pos+1)));
        }
        else
        {
            // error
            this->containerName = path;
            //this->prefix.clear();
        }
        this->containerClient = BlobContainerClient::CreateFromConnectionString(connectionString, containerName);
        if (this->createContainerIfNotExists)
        {
            this->containerClient.CreateIfNotExists();
        }
    }

    std::shared_ptr<StorageItem> AzureStorage::addFilePath(const std::string& path)
    {
        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
        std::size_t pos;

        if ((pos = path.find("/")) != std::string::npos)
        {
            this->containerName = path.substr(0, pos);
            this->pathPrefix.clear();
            this->items.push_back(std::make_shared<StorageItem>(this->containerName + "/" + path.substr(pos+1)));
        }
        else
        {
            throw std::runtime_error("Illegal file path.");
        }

        this->containerClient = BlobContainerClient::CreateFromConnectionString(connectionString, containerName);
        if (this->createContainerIfNotExists)
        {
            this->containerClient.CreateIfNotExists();
        }

        return this->items.back();
    }

    void AzureStorage::requestDownload(const std::shared_ptr<StorageItem>& target)
    {
        auto result = std::find(this->items.begin(), this->items.end(), target);
        if (result==this->items.end())
        {
            throw std::runtime_error("AzureStorage::requestDownload target not found");
        }
        else
        {
            auto dupChk = std::find(this->completeItems.begin(), this->completeItems.end(), target);
            if (dupChk != this->completeItems.end())
                return;

            std::lock_guard<std::recursive_mutex> lk1(this->mutexInstanceMembers);
            (*result)->requestDownload();

            std::lock_guard<std::recursive_mutex> lk2(this->mutexDownloadQueue);
            this->downloadTasks.push(*result);

            this->condWorkers.notify_one();
        }
        return;
    }

    void AzureStorage::putItem(std::shared_ptr<StorageItem> item)
    {
        std::size_t offset = 0;
        if (!this->containerName.empty())
        {
            offset += this->containerName.length() + 1;
        }
        auto path = item->getPath();
        path.erase(0, offset);
        auto blockBlobClient = this->containerClient.GetBlockBlobClient(path);
        auto response = blockBlobClient.UploadFrom(static_cast<const uint8_t*>(item->getRawData()), item->getSize());

        /* check response status */

        return;
    }

    void AzureStorage::waitAllTask()
    {
        this->stop = true;
        this->condWorkers.notify_all();

        for (auto& item: this->downloadWorkers)
        {
            item.join();
        }
        return;
    }

    std::vector<std::shared_ptr<StorageItem>> AzureStorage::getFiles()
    {
        std::lock_guard<std::recursive_mutex> lk(this->mutexSdk);

        if (this->connectionString.empty())
        {
            return this->items;
        }

        if (this->containerName.empty())
        {
            return this->items;
        }

        if (!this->items.empty())
        {
            return this->items;
        }

        this->containerClient = BlobContainerClient::CreateFromConnectionString(this->connectionString, this->containerName);
        auto listBlobsOptions = ListBlobsOptions();
        listBlobsOptions.Prefix = this->pathPrefix;
        auto listBlobsResponse = containerClient.ListBlobs(listBlobsOptions);
        this->items.reserve(listBlobsResponse.Blobs.size());

        for (auto blobItem : listBlobsResponse.Blobs)
        {
            std::string path;
            if (!this->containerName.empty())
            {
                path += this->containerName+"/";
            }
            path += blobItem.Name;
            this->items.push_back(std::make_shared<StorageItem>(path));
        }

        return this->items;
    }
    
    /*
     *  Try to delete file/folder in Azure
     */
    bool AzureStorage::requestDelete(std::string target, std::string format, bool is_dir)
    {
        this->containerClient = BlobContainerClient::CreateFromConnectionString(this->connectionString, this->containerName);

        if(is_dir)
        {
            auto items = this->getFiles();
            int itemCount = items.size();

            if (itemCount == 0) {
                return false;
            }

            for(int i=0; i<itemCount; i++)
            {
                auto item = items[i];
                if(item == nullptr)
                {
                    continue;
                }

                auto itemPath = item->getPath();
            
                auto p = SplitBucketPath(itemPath);
                auto blod = this->containerClient.GetBlobClient(p.second);
                auto result = blod.DeleteIfExists();

                if (!result.Value.Deleted)
                {
                    return false;
                }
            }

            this->items.clear();
            this->completeItems.clear();
        }
        else 
        {

            auto p = SplitBucketPath(target);
            auto blod = this->containerClient.GetBlobClient(p.second);
            auto result = blod.DeleteIfExists();

            if (!result.Value.Deleted)
            {
                return false;
            }
            
            this->items.clear();
            this->completeItems.clear();
        }
        return true;
    }

    /*
     * Check single file exist in Azure
     * Because No direct API to check. Get list object in Blob then iter
     */
    bool AzureStorage::is_file_exist(std::string path)
    {
        std::string folder = "";
        auto p = SplitBucketPath(path);
        this->containerClient = BlobContainerClient::CreateFromConnectionString(this->connectionString, this->containerName);
        auto listBlobsOptions = ListBlobsOptions();

        if (p.second.find_last_of("/\\") != std::string::npos)
        {
            folder = p.second.substr(0, p.second.find_last_of("/\\"));
            listBlobsOptions.Prefix = this->pathPrefix;
        }
        auto listBlobsResponse = containerClient.ListBlobs(listBlobsOptions);
        for (auto&& blodItem : listBlobsResponse.Blobs)
        {
            std::string filepath =  folder + blodItem.Name;
            if ( filepath == path) {
                return true;
            }
        }

        return false;
    }
}
