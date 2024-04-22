#include "gcpStorage.hpp"
#include <stdlib.h>
#include <unistd.h>

namespace ObjStorageFdw
{
    std::shared_ptr<GcpStorage> GcpStorage::GetInstance(unsigned int id)
    {
        if (Storage::instancePool.find(id) == Storage::instancePool.end())
        {
            Storage::instancePool.insert(std::make_pair(id, std::make_shared<GcpStorage>(id)));
        }
        else if (!std::dynamic_pointer_cast<GcpStorage>(Storage::instancePool.at(id)))
        {
            throw std::runtime_error("[ERROR] exist Storage instance but different type "  + std::to_string(id));
        }
        return std::dynamic_pointer_cast<GcpStorage>(Storage::instancePool.at(id));
    }

    GcpStorage::GcpStorage(unsigned int id)
    : Storage(id),
    restEndpoint(std::string()),
    bucketName(std::string()),
    createBucketIfNotExists(false),
    bucketExist(false)
    {
        return;
    }

    GcpStorage::~GcpStorage()
    {
        this->finalize();
    }

    int GcpStorage::initialize(const std::string& restEndpoint, const bool& createBucketIfNotExists, const bool& suppressRetry, char *project_id)
    {
        std::lock_guard<std::recursive_mutex> lk(this->mutexSdk);

        if (this->initialized)
        {
            return -1;
        }

        this->restEndpoint = restEndpoint;
        this->createBucketIfNotExists = createBucketIfNotExists;

        auto options = ::google::cloud::Options();
        options.set<::google::cloud::storage::RestEndpointOption>(this->restEndpoint);
        options.set<::google::cloud::UnifiedCredentialsOption>(::google::cloud::MakeInsecureCredentials());
        options.set<::google::cloud::storage::ProjectIdOption>(project_id);
        if (suppressRetry)
        {
            options.set<::google::cloud::storage::DownloadStallTimeoutOption>(std::chrono::seconds(1));
            options.set<::google::cloud::storage::RetryPolicyOption>(::google::cloud::storage::LimitedErrorCountRetryPolicy(1).clone());
        }

        this->client = ::google::cloud::storage::Client(options);

        this->finalize();
        this->stop = false;
        for (int i = 0; i < Storage::maxConcurrent; i++)
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
                        if (this->stop)
                        {
                            return;
                        }
                        downloadItem = this->downloadTasks.front();
                        this->downloadTasks.pop();
                    }

                    {
                        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
                        downloadItem->startDownload();
                        std::lock_guard<std::recursive_mutex> lkClass(Storage::mutexClassMembers);
                        Storage::inProgress++;
                    }

                    // download
                    std::size_t offset = 0;

                    if (!this->bucketName.empty())
                    {
                        offset += this->bucketName.length()+1;
                    }
                    auto path = downloadItem->getPath();
                    path.erase(0, offset);

                    auto metaData = this->client.GetObjectMetadata(this->bucketName, path);

                    if (!metaData)
                    {
                        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
                        downloadItem->completeDownload(false, metaData.status().message(), metaData.status().code() == ::google::cloud::StatusCode::kNotFound);
                    }
                    else
                    {
                        auto inputStream = this->client.ReadObject(this->bucketName, path);

                        if (inputStream.bad())
                        {
                            std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
                            downloadItem->completeDownload(false, "GcpStorage: input stream is bad: " + inputStream.status().message());
                        }
                        else
                        {
                            std::vector<unsigned char> buffer(std::istreambuf_iterator<char>(inputStream), {});
                            std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
                            downloadItem->setRawData(&buffer[0], buffer.size());
                            downloadItem->completeDownload(true);
                        }
                    }

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

    void GcpStorage::finalize()
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
        this->bucketName.clear();
        this->pathPrefix.clear();

        return;
    }

    void GcpStorage::setDirPath(const std::string& path)
    {
        // 既存のファイル一覧は消す。
        // 進行中のダウンロードは続いてしまうが無視される事になるからよし。
        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
        this->completeItems.clear();
        this->items.clear();

        std::size_t pos;
        if ((pos=path.find("/")) != std::string::npos)
        {
            this->bucketName = path.substr(0, pos);
            this->pathPrefix = path.substr(pos+1);
        }
        else
        {
            this->bucketName = path;
            this->pathPrefix.clear();
        }

        auto bucketMetadata = this->client.GetBucketMetadata(this->bucketName);
        if (!bucketMetadata)
        {
            if (bucketMetadata.status().code()==::google::cloud::StatusCode::kNotFound)
            {
                this->bucketExist = false;
            }
            else
            {
                this->bucketExist = true;
            }
        }
        else
        {
            this->bucketExist = true;
        }

        return;
    }

    void GcpStorage::setFilePath(const std::string& path)
    {
        // 既存のファイル一覧は消す。
        // 進行中のダウンロードは続いてしまうが無視される事になるからよし。
        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
        this->completeItems.clear();
        this->items.clear();

        std::size_t pos;
        if ((pos=path.find("/")) != std::string::npos)
        {
            this->bucketName = path.substr(0, pos);
            this->pathPrefix.clear();
            this->items.push_back(std::make_shared<StorageItem>(this->bucketName + "/" + path.substr(pos+1)));
        }
        else
        {
            throw std::runtime_error("Illegal path: " + path);
        }

        auto bucketMetadata = this->client.GetBucketMetadata(this->bucketName);
        if (!bucketMetadata)
        {
            if (bucketMetadata.status().code()==::google::cloud::StatusCode::kNotFound)
            {
                this->bucketExist = false;
            }
            else
            {
                throw std::runtime_error(bucketMetadata.status().message());
            }
        }
        else
        {
            this->bucketExist = true;
        }

        return;
    }

    std::shared_ptr<StorageItem> GcpStorage::addFilePath(const std::string& path)
    {
        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);

        std::size_t pos;
        if ((pos=path.find("/")) != std::string::npos)
        {
            this->bucketName = path.substr(0, pos);
            this->pathPrefix.clear();
            this->items.push_back(std::make_shared<StorageItem>(this->bucketName + "/" + path.substr(pos + 1)));
        }
        else
        {
            throw std::runtime_error("Illegal path: " + path);
        }

        auto bucketMetadata = this->client.GetBucketMetadata(this->bucketName);
        if (!bucketMetadata)
        {
            if (bucketMetadata.status().code()==::google::cloud::StatusCode::kNotFound)
            {
                this->bucketExist = false;
            }
            else
            {
                throw std::runtime_error(bucketMetadata.status().message());
            }
        }
        else
        {
            this->bucketExist = true;
        }

        return this->items.back();
    }

    std::vector<std::shared_ptr<StorageItem>> GcpStorage::getFiles()
    {
        std::lock_guard<std::recursive_mutex> lk(this->mutexSdk);

        if (!this->items.empty())
        {
            return this->items;
        }

        if (this->bucketName.empty())
        {
            return this->items;
        }

        for (auto&& object_metadata : this->client.ListObjects(this->bucketName, google::cloud::storage::Prefix(this->pathPrefix)))
        {
            if (!object_metadata)
            {
                throw std::runtime_error(object_metadata.status().message());
            }
            std::string path;
            if (!this->bucketName.empty())
            {
                path += this->bucketName+"/";
            }
            path += object_metadata->name();
            this->items.push_back(std::make_shared<StorageItem>(path));
        }

        return this->items;
    }

    void GcpStorage::requestDownload(const std::shared_ptr<StorageItem>& target)
    {
        auto result = std::find(this->items.begin(), this->items.end(), target);
        if (result == this->items.end())
        {
            throw std::runtime_error("GcpStorage: target not found");
        }
        else
        {
            auto dupChk = std::find(this->completeItems.begin(), this->completeItems.end(), target);
            if (dupChk != this->completeItems.end())
            {
                return;
            }

            (*result)->requestDownload();
            {
                std::lock_guard<std::recursive_mutex> lk(this->mutexDownloadQueue);
                this->downloadTasks.push(*result);
            }
            this->condWorkers.notify_one();
        }
        return;
    }

    void GcpStorage::putItem(std::shared_ptr<StorageItem> item)
    {
        if (!this->bucketExist)
        {
            if (this->createBucketIfNotExists)
            {
                auto metadata = this->client.CreateBucket(this->bucketName, ::google::cloud::storage::BucketMetadata());
                if (!metadata)
                {
                   throw std::move(metadata).status();
                }
                else
                {
                    this->bucketExist = true;
                }
            }
            else
            {
                throw std::runtime_error("Error: Bucket not exists : " + this->bucketName);
            }
        }

        int tmpFd;
        char tmpFilename[] = "/tmp/gcsTempXXXXXX";
        tmpFd = mkstemp(tmpFilename);
        write(tmpFd, item->getRawData(), item->getSize());
        close(tmpFd);

        std::size_t offset = 0;
        if (!this->bucketName.empty())
        {
            offset += this->bucketName.length() + 1;
        }
        auto path = item->getPath();
        path.erase(0, offset);
        auto metadata = this->client.UploadFile(tmpFilename, this->bucketName, path);

        if (!metadata)
            throw std::runtime_error(metadata.status().message());

        remove(tmpFilename);

        return;
    }

    void GcpStorage::waitAllTask()
    {
        this->stop = true;
        this->condWorkers.notify_all();
        for (auto& item: this->downloadWorkers)
        {
            item.join();
        }

        return;
    }

    /*
     *  Try to delete file/folder in GCP
     */
    bool GcpStorage::requestDelete(std::string target, std::string format, bool is_dir)
    {

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
                auto status = this->client.DeleteObject(this->bucketName, p.second);

                if (!status.ok())
                {
                    if (status.code()==::google::cloud::StatusCode::kNotFound)
                    {
                        return false;
                    }
                    else
                    {
                        throw std::runtime_error(status.message());
                    }
                }
            }

            this->items.clear();
            this->completeItems.clear();
        }
        else 
        {

            auto p = SplitBucketPath(target);
            auto status = this->client.DeleteObject(this->bucketName, p.second);

            if (!status.ok())
            {
                if (status.code()==::google::cloud::StatusCode::kNotFound)
                {
                    return false;
                }
                else
                {
                    throw std::runtime_error(status.message());
                }
            }
            
            this->items.clear();
            this->completeItems.clear();
        }
        return true;
    }

    /*
     * Check single file exist in GCP
     * Because No direct API to check. Get list object in Bucket then iter
     */
    bool GcpStorage::is_file_exist(std::string path)
    {
        std::string folder = "";
        auto p = SplitBucketPath(path);
        if (p.second.find_last_of("/\\") != std::string::npos)
        {
            folder = p.second.substr(0, p.second.find_last_of("/\\"));
            for (auto&& object_metadata : this->client.ListObjects(this->bucketName, google::cloud::storage::Prefix(folder)))
            {
                if (!object_metadata)
                {
                    if (object_metadata.status().code()==::google::cloud::StatusCode::kNotFound)
                    {
                        return false;
                    }
                    else
                    {
                        throw std::runtime_error(object_metadata.status().message());
                    }
                }
                std::string filepath =  folder + object_metadata->name();
                if ( filepath == path) 
                {
                    return true;
                }
            }
        }
        else
        {
            for (auto&& object_metadata : this->client.ListObjects(this->bucketName))
            {
                if (!object_metadata)
                {
                    if (object_metadata.status().code()==::google::cloud::StatusCode::kNotFound)
                    {
                        return false;
                    }
                    else
                    {
                        throw std::runtime_error(object_metadata.status().message());
                    }
                }
                std::string filepath =  folder + object_metadata->name();
                if ( filepath == path) 
                {
                    return true;
                }
            }
        }

        return false;
    }
}
