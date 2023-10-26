#include "azureStorage.hpp"

#include <sstream>

namespace ObjStorageFdw
{
    using namespace Azure::Storage::Blobs;

    std::shared_ptr<AzureStorage> AzureStorage::GetInstance(unsigned int id)
    {
        if (Storage::instancePool.find(id) == Storage::instancePool.end())
        {
            std::cout << "create new AzureStorage instance " << id << std::endl;
            Storage::instancePool.insert(std::make_pair(id, std::make_shared<AzureStorage>(id)));
        }
        else if(!std::dynamic_pointer_cast<AzureStorage>(Storage::instancePool.at(id)))
        {
            std::cout << "[ERROR] exist Storage instance but different type " << id << std::endl;
            return std::shared_ptr<AzureStorage>();
        }
        else
        {
            std::cout << "return existing AzureStorage instance " << id << std::endl;
        }
        return std::dynamic_pointer_cast<AzureStorage>(Storage::instancePool.at(id));
    }

    AzureStorage::AzureStorage(unsigned int id)
    : containerClient(Azure::Storage::Blobs::BlobContainerClient::CreateFromConnectionString("", "")),
    stop(false),
    Storage(id),
    createContainerIfNotExists(false)
    {
        return;
    }

    AzureStorage::~AzureStorage()
    {
        std::cout << "AzureStorage::~AzureStorage() " << this->id << std::endl;
        this->finalize();
    }

    int AzureStorage::initialize(const std::string& connectionString, const bool& createContainerIfNotExists)
    {
        std::cout << "AzureStorage::initialize() " << connectionString << std::endl;
        std::lock_guard<std::recursive_mutex> lk(this->mutexSdk);

        if(this->initialized)
        {
            std::cout << "already initialized" << std::endl;
            return -1;
        }

        this->connectionString = connectionString;
        this->createContainerIfNotExists = createContainerIfNotExists;

        //this->azureClientHoge = Azure::Storage::Blobs::BlobContainerClient::CreateFromConnectionString("hoge", "hoge");
        //this->azureClient.reset(&Azure::Storage::Blobs::BlobContainerClient::CreateFromConnectionString("hoge", "hoge"));
        this->containerClient = BlobContainerClient::CreateFromConnectionString(connectionString, containerName);

        this->finalize();
        this->stop = false;
        for(int i=0; i<Storage::maxConcurrent; i++)
        {
            this->downloadWorkers.push_back(std::thread([this]
            {
                std::shared_ptr<StorageItem> downloadItem;
                while(true)
                {
                    {
                        std::unique_lock<std::recursive_mutex> lock(this->mutexDownloadQueue);
                        while(!this->stop && this->downloadTasks.empty())
                        {
                            this->condWorkers.wait(lock);
                        }
                        if(this->stop)
                        {
                            return;
                        }
                        downloadItem = this->downloadTasks.front();
                        this->downloadTasks.pop();
                    }

                    // download
                    std::vector<uint8_t> buffer;
                    std::size_t offset = 0;
                    if(!this->containerName.empty())
                    {
                        offset += this->containerName.length() + 1;
                    }
                    auto path = downloadItem->getPath();
                    path.erase(0, offset);
                    std::cout << "item path     : " << downloadItem->getPath() << std::endl;
                    std::cout << "download path : " << path << std::endl;
                    auto blockBlobClient = this->containerClient.GetBlockBlobClient(path);
                    {
                        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
                        downloadItem->startDownload();
                        std::lock_guard<std::recursive_mutex> lkClass(Storage::mutexClassMembers);
                        Storage::inProgress++;
                    }
                    std::cout << "Blob name: " << downloadItem->getPath() << std::endl;
                    try
                    {
                        auto blobProperties = blockBlobClient.GetProperties();
                        buffer.resize(static_cast<size_t>(blobProperties.Value.BlobSize));
                        auto response = blockBlobClient.DownloadTo(buffer.data(), buffer.size());
                        // エラー判断の方法が分からぬ…
                        {
                            std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
                            downloadItem->setRawData(&buffer[0], buffer.size());
                            std::cout << "notify complete \"" << downloadItem->getPath() << "\"" << std::endl;
                            downloadItem->completeDownload(true);
                            this->completeItems.push_back(downloadItem);
                            std::lock_guard<std::recursive_mutex> lkClass(Storage::mutexClassMembers);
                            Storage::inProgress--;
                        }
                    }
                    catch (...)
                    {
                        std::cout << "catch exception" << std::endl;
                        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
                        downloadItem->completeDownload(false);
                        this->completeItems.push_back(downloadItem);
                        std::lock_guard<std::recursive_mutex> lkClass(Storage::mutexClassMembers);
                        Storage::inProgress--;
                        this->condInstanceMembers.notify_all();
                        return;
                    }
                    this->condInstanceMembers.notify_all();
                }
            }));
        }

        this->initialized = true;
        return 0;
    }

    void AzureStorage::finalize()
    {
        std::cout << "AzureStorage::finalize()" << std::endl;

        this->stop = true;
        this->condWorkers.notify_all();
        for(auto& item: this->downloadWorkers)
        {
            item.join();
        }
        this->downloadWorkers.clear();

        // 既存のファイル一覧は消す。
        // 進行中のダウンロードは続いてしまうが無視される事になるからよし。
        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
        this->completeItems.clear();
        this->items.clear();

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
        if((pos=path.find("/")) != std::string::npos)
        {
            this->containerName = path.substr(0, pos);
            this->pathPrefix = path.substr(pos+1);
            //std::cout << "bucket:" << this->bucketName << " prefix:" << this->prefix << std::endl;
        }
        else
        {
            this->containerName = path;
            this->pathPrefix.clear();
        }
        std::cout << "AzureStorage::setDirPath() " << path << " containerName:" << this->containerName << std::endl;
        this->containerClient = BlobContainerClient::CreateFromConnectionString(connectionString, containerName);
        if(this->createContainerIfNotExists)
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
        if((pos=path.find("/")) != std::string::npos)
        {
            this->containerName = path.substr(0, pos);
            this->pathPrefix.clear();
            this->items.push_back(std::make_shared<StorageItem>(this->containerName + "/" + path.substr(pos+1)));
            std::cout << "bucket:" << this->containerName << " file:" << this->items[0]->getPath() << std::endl;
        }
        else
        {
            // error
            this->containerName = path;
            //this->prefix.clear();
        }
        this->containerClient = BlobContainerClient::CreateFromConnectionString(connectionString, containerName);
        if(this->createContainerIfNotExists)
        {
            this->containerClient.CreateIfNotExists();
        }
    }

    void AzureStorage::requestDownload(const std::shared_ptr<StorageItem>& target)
    {
        auto result = std::find(this->items.begin(), this->items.end(), target);
        if(result==this->items.end())
        {
            std::cout << "target not found" << std::endl;
        }
        else
        {
            std::cout << "target found " << result-this->items.begin() << std::endl;
            auto dupChk = std::find(this->completeItems.begin(), this->completeItems.end(), target);
            if(dupChk!=this->completeItems.end())
            {
                // エラー時の再ダウンロードを考慮していない。
                std::cout << "already downloaded" << std::endl;
                return;
            }

            {
                std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
                (*result)->requestDownload();
            }
            {
                std::lock_guard<std::recursive_mutex> lk(this->mutexDownloadQueue);
                this->downloadTasks.push(*result);
            }
            this->condWorkers.notify_one();
        }
        //this->refreshDownloadTask();
        return;
    }

    std::shared_ptr<StorageItem> AzureStorage::getAnyOne()
    {
        std::cout << "getAnyOne() " << this->items.size() << std::endl;
        // comopleteなItemが無かったら起こされるまで待つ
        // 起きたらitemsを確認、completeが無かったらまた待つ
        std::unique_lock<std::recursive_mutex> lk(this->mutexInstanceMembers);
        std::size_t targetNum = this->completeItems.size();
        this->condInstanceMembers.wait(lk, [this, targetNum]{
            if(this->completeItems.size() >= this->items.size())
            {
                // 全て完了している
                return true;
            }
            if(targetNum >= this->completeItems.size())
            {
                // 完了してるアイテムがまだ少ない
                return false;
            }
            // 何か完了した
            return true;
        });
        
        if(targetNum < this->completeItems.size())
        {
            auto item = this->completeItems[targetNum];
            if(item->getState() == StorageItem::ItemState::complete)
            {
                return item;
            }
            //return this->completeItems[this->returnedCur++];
        }

        //return std::make_shared<StorageItem>(nullptr);
        return std::shared_ptr<StorageItem>();
    }

    std::shared_ptr<StorageItem> AzureStorage::get(int pos)
    {
        std::cout << "items " << this->items.size() << " completeItems " << this->completeItems.size() << std::endl;
        std::unique_lock<std::recursive_mutex> lk(this->mutexInstanceMembers);

        if(pos>=this->completeItems.size())
        {
            std::cout << "out of range" << std::endl;
            std::shared_ptr<StorageItem> nullItem;
            return nullItem;
        }

        return this->completeItems[pos];
    }

    void AzureStorage::putItem(std::shared_ptr<StorageItem> item)
    {
        std::size_t offset = 0;
        if(!this->containerName.empty())
        {
            offset += this->containerName.length() + 1;
        }
        auto path = item->getPath();
        path.erase(0, offset);
        auto blockBlobClient = this->containerClient.GetBlockBlobClient(path);
        auto response = blockBlobClient.UploadFrom(static_cast<const uint8_t*>(item->getRawData()), item->getSize());
        std::cout << "AzureStorage::putItem() " << response.RawResponse->GetReasonPhrase() << std::endl;
        return;
    }

    void AzureStorage::waitAllTask()
    {
        std::cout << "AzureStorage::waitAllTask()" << std::endl;
        // 新規のダウンロードタスクを追加できない状態にして
        // 進行中のタスクの完了を待つ(現状キャンセルをサポートしていないので)
        // 全itemのstatusを確認してみる。クラス変数の進行数を見ても良いはず。
        //std::unique_lock<std::mutex> lk(this->mutexInstanceMembers);
        //this->condInstanceMembers.wait(lk, [this]{
        //    bool inProgress = false;
        //    for(auto item : this->items)
        //    {
        //        if(StorageItem::ItemState::inProgress == item->getState())
        //        {
        //            inProgress = true;
        //        }
        //    }
        //    return !inProgress;
        //});

        this->stop = true;
        this->condWorkers.notify_all();
        for(auto& item: this->downloadWorkers)
        {
            item.join();
        }

        return;
    }

    std::vector<std::shared_ptr<StorageItem>> AzureStorage::getFiles()
    {
        std::lock_guard<std::recursive_mutex> lk(this->mutexSdk);

        if(this->connectionString.empty())
        {
            return this->items;
        }

        if(this->containerName.empty())
        {
            return this->items;
        }

        if(!this->items.empty())
        {
            return this->items;
        }

        this->containerClient = BlobContainerClient::CreateFromConnectionString(this->connectionString, this->containerName);
        //auto containerClient = BlobContainerClient::CreateFromConnectionString(this->connectionString, this->containerName);
        //this->containerClient.reset(&containerClient);
        //containerClient.CreateIfNotExists();
        auto listBlobsOptions = ListBlobsOptions();
        listBlobsOptions.Prefix = this->pathPrefix;
        auto listBlobsResponse = containerClient.ListBlobs(listBlobsOptions);
        std::cout << "Blobs " << this->containerName << " " << this->pathPrefix << " Blob count: " << listBlobsResponse.Blobs.size() << std::endl;
        this->items.reserve(listBlobsResponse.Blobs.size());
        for(auto blobItem : listBlobsResponse.Blobs)
        {
            std::cout << "Blob name: " << blobItem.Name << " " << blobItem.BlobSize << std::endl;
            std::string path;
            if(!this->containerName.empty())
            {
                path += this->containerName+"/";
            }
            path += blobItem.Name;
            this->items.push_back(std::make_shared<StorageItem>(path));
        }
        //this->containerClient.reset();

        return this->items;
    }
}
