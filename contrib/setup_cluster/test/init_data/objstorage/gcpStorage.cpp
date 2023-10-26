#include "gcpStorage.hpp"
#include <stdlib.h>
#include <unistd.h>

namespace ObjStorageFdw
{
    std::shared_ptr<GcpStorage> GcpStorage::GetInstance(unsigned int id)
    {
        if (Storage::instancePool.find(id) == Storage::instancePool.end())
        {
            std::cout << "create new GcpStorage instance " << id << std::endl;
            Storage::instancePool.insert(std::make_pair(id, std::make_shared<GcpStorage>(id)));
        }
        else if(!std::dynamic_pointer_cast<GcpStorage>(Storage::instancePool.at(id)))
        {
            std::cout << "[ERROR] exist Storage instance but different type " << id << std::endl;
            return std::shared_ptr<GcpStorage>();
        }
        else
        {
            std::cout << "return existing GcpStorage instance " << id << std::endl;
        }
        return std::dynamic_pointer_cast<GcpStorage>(Storage::instancePool.at(id));
    }

    GcpStorage::GcpStorage(unsigned int id)
    : Storage(id),
    createBucketIfNotExists(false),
    bucketExist(false)
    {
        return;
    }

    GcpStorage::~GcpStorage()
    {
        std::cout << "GcpStorage::~GcpStorage() " << this->id << std::endl;
        this->finalize();
    }

    int GcpStorage::initialize(const std::string& restEndpoint, const bool& createBucketIfNotExists)
    {
        std::lock_guard<std::recursive_mutex> lk(this->mutexSdk);

        if(this->initialized)
        {
            std::cout << "already initialized" << std::endl;
            return -1;
        }

        this->restEndpoint = restEndpoint;
        this->createBucketIfNotExists = createBucketIfNotExists;

        auto options = ::google::cloud::Options();
        options.set<::google::cloud::storage::RestEndpointOption>(this->restEndpoint);
        options.set<::google::cloud::UnifiedCredentialsOption>(::google::cloud::MakeInsecureCredentials());
        options.unset<::google::cloud::storage::ProjectIdOption>();

        this->client = ::google::cloud::storage::Client(options);

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

                    {
                        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
                        downloadItem->startDownload();
                        std::lock_guard<std::recursive_mutex> lkClass(Storage::mutexClassMembers);
                        Storage::inProgress++;
                    }

                    // download
                    std::size_t offset = 0;
                    if(!this->bucketName.empty())
                    {
                        offset += this->bucketName.length()+1;
                    }
                    auto path = downloadItem->getPath();
                    path.erase(0, offset);
                    std::cout << "item path     : " << downloadItem->getPath() << std::endl;
                    std::cout << "download path : " << path << std::endl;
                    auto metaData = this->client.GetObjectMetadata(this->bucketName, path);
                    if(metaData)
                    {
                        std::cout << "object:" << metaData->name() << " size:" << metaData->size() << std::endl;
                    }
                    else
                    {
                        std::cout << "GetObjectMetadata failed" << std::endl;
                        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
                        downloadItem->completeDownload(false);
                        std::lock_guard<std::recursive_mutex> lkClass(Storage::mutexClassMembers);
                        Storage::inProgress--;
                        this->completeItems.push_back(downloadItem);
                        this->condInstanceMembers.notify_all();
                        return;
                    }

                    auto inputStream = this->client.ReadObject("download/storage/v1/b/"+this->bucketName, "o/"+path);
                    if(inputStream.bad())
                    {
                        std::cout << "input stream is bad" << std::endl;
                        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
                        downloadItem->completeDownload(false);
                        std::lock_guard<std::recursive_mutex> lkClass(Storage::mutexClassMembers);
                        Storage::inProgress--;
                        this->completeItems.push_back(downloadItem);
                        this->condInstanceMembers.notify_all();
                        return;
                    }
                    inputStream.status();
                    std::vector<unsigned char> buffer(std::istreambuf_iterator<char>(inputStream), {});
                    std::cout << "object:" << downloadItem->getPath() << " size:" << buffer.size() << std::endl;

                    {
                        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
                        downloadItem->setRawData(&buffer[0], buffer.size());
                        downloadItem->completeDownload(true);
                        this->completeItems.push_back(downloadItem);
                        std::lock_guard<std::recursive_mutex> lkClass(Storage::mutexClassMembers);
                        Storage::inProgress--;
                    }
                    this->condInstanceMembers.notify_all();
                }
            }));
        }

        this->initialized = true;
        return 0;
    }

    void GcpStorage::finalize()
    {
        std::cout << "GcpStorage::finalize()" << std::endl;
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

    void GcpStorage::setDirPath(const std::string& path)
    {
        // 既存のファイル一覧は消す。
        // 進行中のダウンロードは続いてしまうが無視される事になるからよし。
        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
        this->completeItems.clear();
        this->items.clear();

        std::size_t pos;
        if((pos=path.find("/")) != std::string::npos)
        {
            this->bucketName = path.substr(0, pos);
            this->pathPrefix = path.substr(pos+1);
            //std::cout << "bucket:" << this->bucketName << " prefix:" << this->prefix << std::endl;
        }
        else
        {
            this->bucketName = path;
            this->pathPrefix.clear();
        }

        auto bucketMetadata = this->client.GetBucketMetadata(this->bucketName);
        if(!bucketMetadata)
        {
            if(bucketMetadata.status().code()==::google::cloud::StatusCode::kNotFound)
            {
                this->bucketExist = false;
            }
            else
            {
                std::cout << "unrecoverable error" << std::endl;
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
        if((pos=path.find("/")) != std::string::npos)
        {
            this->bucketName = path.substr(0, pos);
            this->pathPrefix.clear();
            this->items.push_back(std::make_shared<StorageItem>(this->bucketName+"/"+path.substr(pos+1)));
            std::cout << "bucket:" << this->bucketName << " file:" << path.substr(pos+1) << std::endl;
        }
        else
        {
            // error
        }

        auto bucketMetadata = this->client.GetBucketMetadata(this->bucketName);
        if(!bucketMetadata)
        {
            if(bucketMetadata.status().code()==::google::cloud::StatusCode::kNotFound)
            {
                this->bucketExist = false;
            }
            else
            {
                std::cout << "unrecoverable error" << std::endl;
            }
        }
        else
        {
            this->bucketExist = true;
        }

        return;
    }

    std::vector<std::shared_ptr<StorageItem>> GcpStorage::getFiles()
    {
        std::cout << "GcpStorage::getFiles()" << std::endl;
        std::lock_guard<std::recursive_mutex> lk(this->mutexSdk);

        if(!this->items.empty())
        {
            return this->items;
        }
        
        if(this->bucketName.empty())
        {
            return this->items;
        }

        std::cout << "search: " << this->bucketName << std::endl;
        
        //auto objects = this->client.ListObjects(this->bucketName);
        for (auto&& object_metadata : this->client.ListObjects(this->bucketName, google::cloud::storage::Prefix(this->pathPrefix)))
        {
            if (!object_metadata)
            {
                throw std::runtime_error(object_metadata.status().message());
            }
            std::cout << "bucket_name=" << object_metadata->bucket() << ", object_name=" << object_metadata->name() << " object_size=" << object_metadata->size() << std::endl;
            std::string path;
            if(!this->bucketName.empty())
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

            (*result)->requestDownload();
            {
                std::lock_guard<std::recursive_mutex> lk(this->mutexDownloadQueue);
                this->downloadTasks.push(*result);
            }
            this->condWorkers.notify_one();
        }
        //this->refreshDownloadTask();
        return;
    }

    std::shared_ptr<StorageItem> GcpStorage::getAnyOne()
    {
        std::cout << "getAnyOne() " << this->items.size() << std::endl;
        // comopleteなItemが無かったら起こされるまで待つ
        // 起きたらitemsを確認、completeが無かったらまた待つ
        std::unique_lock<std::recursive_mutex> lk(this->mutexInstanceMembers);
        auto targetNum = this->completeItems.size();
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

    std::shared_ptr<StorageItem> GcpStorage::get(int pos)
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

    void GcpStorage::putItem(std::shared_ptr<StorageItem> item)
    {
        std::cout << "GcpStorage::putItem() " << this->bucketName << " " << item->getPath() << std::endl;

        if(!this->bucketExist)
        {
            if(this->createBucketIfNotExists)
            {
                auto metadata = this->client.CreateBucket(this->bucketName, ::google::cloud::storage::BucketMetadata());
                if(!metadata)
                {
                    std::cout << metadata.status().message() << std::endl;
                }
                else
                {
                    this->bucketExist = true;
                }
            }
            else
            {
                std::cout << "Error: Bucket not exists : " << this->bucketName << std::endl;
            }
        }

        int tmpFd;
        char tmpFilename[] = "/tmp/gcsTempXXXXXX";
        tmpFd = mkstemp(tmpFilename);
        write(tmpFd, item->getRawData(), item->getSize());
        close(tmpFd);

        std::size_t offset = 0;
        if(!this->bucketName.empty())
        {
            offset += this->bucketName.length() + 1;
        }
        auto path = item->getPath();
        path.erase(0, offset);
        auto metadata = this->client.UploadFile(tmpFilename, this->bucketName, path);

        remove(tmpFilename);

        //this->client.UploadFile("/home/acky/public_html/index.php", this->bucketName, item->getPath());
        //auto outputStream = this->client.WriteObject(this->bucketName, item->getPath());
        //if(outputStream.bad())
        //{
        //    std::cout << "output stream is bad" << std::endl;
        //    return;
        //}
        //else
        //{
        //    std::cout << "output stream is normal" << std::endl;
        //}
        //outputStream.write(static_cast<const char*>(item->getRawData()), item->getSize());
        //outputStream << "test strings" << std::endl;
        //std::cout << "write" << std::endl;
        //outputStream.Close();
        //std::cout << "close" << std::endl;
        //google::cloud::StatusOr<google::cloud::storage::ObjectMetadata> metadata = std::move(outputStream).metadata();
        //std::cout << "Successfully wrote to object " << metadata->name()
        //    << " its size is: " << metadata->size()
        //    << "\nFull metadata: " << *metadata << "\n";
        return;

    }

    void GcpStorage::waitAllTask()
    {
        std::cout << "GcpStorage::waitAllTask()" << std::endl;
        // 新規のダウンロードタスクを追加できない状態にして
        // 進行中のタスクの完了を待つ(現状キャンセルをサポートしていないので)
        // 全itemのstatusを確認してみる。クラス変数の進行数を見ても良いはず。
        //std::unique_lock<std::recursive_mutex> lk(this->mutexSdk);
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
}
