#include "s3Storage.hpp"
#include <aws/s3/model/PutObjectRequest.h>
#include <aws/s3/model/GetBucketAclRequest.h>
#include <aws/s3/model/CreateBucketRequest.h>
#include <boost/interprocess/streams/bufferstream.hpp>

namespace ObjStorageFdw
{
    std::shared_ptr<S3Storage> S3Storage::GetInstance(unsigned int id)
    {
        if (Storage::instancePool.find(id) == Storage::instancePool.end())
        {
            std::cout << "create new S3Storage instance " << id << std::endl;
            Storage::instancePool.insert(std::make_pair(id, std::make_shared<S3Storage>(id)));
        }
        else if(!std::dynamic_pointer_cast<S3Storage>(Storage::instancePool.at(id)))
        {
            std::cout << "[ERROR] exist Storage instance but different type " << id << std::endl;
            return std::shared_ptr<S3Storage>();
        }
        std::cout << "return existing S3Storage instance " << id << std::endl;
        return std::dynamic_pointer_cast<S3Storage>(Storage::instancePool.at(id));
    }

    int S3Storage::sdkInitialized(0);
    Aws::SDKOptions S3Storage::options;

    S3Storage::S3Storage(unsigned int id)
    :Storage(id),
    bucketExist(false),
    createBucketIfNotExists(false)
    {
        std::cout << "S3Storage::S3Storage() " << id << std::endl;

        if(0>=S3Storage::sdkInitialized)
        {
            std::cout << "Aws::InitAPI()" << std::endl;
            S3Storage::options.loggingOptions.logLevel = Aws::Utils::Logging::LogLevel::Info;
            Aws::InitAPI(S3Storage::options);
        }
        S3Storage::sdkInitialized++;
        std::cout << "Aws:: S3Storage::sdkInitialized " << S3Storage::sdkInitialized << std::endl;

        return;
    }

    S3Storage::~S3Storage()
    {
        std::cout << "S3Storage::~S3Storage() " << this->id << std::endl;
        this->finalize();

        S3Storage::sdkInitialized--;
        if(0>=S3Storage::sdkInitialized)
        {
            std::cout << "Aws::ShutdownAPI()" << std::endl;
            Aws::ShutdownAPI(S3Storage::options);
        }
        std::cout << "AWS:: S3Storage::sdkInitialized " << S3Storage::sdkInitialized << std::endl;
    }

    int S3Storage::initialize(const std::string& accessKeyId, const std::string& secretKey, const std::string& region, const std::string& endpoint, const bool createBucketIfNotExists)
    {
        std::lock_guard<std::recursive_mutex> lk(this->mutexSdk);

        if(this->initialized)
        {
            std::cout << "already initialized" << std::endl;
            return -1;
        }

        Aws::Client::ClientConfiguration clientConfig;
        auto cred = Aws::Auth::AWSCredentials(accessKeyId, secretKey);

        if(!endpoint.empty())
        {
            clientConfig.scheme = Aws::Http::Scheme::HTTP;
            clientConfig.endpointOverride = endpoint;

            this->s3Client = std::make_shared<Aws::S3::S3Client>(cred, clientConfig, Aws::Client::AWSAuthV4Signer::PayloadSigningPolicy::Never, false);
        }
        else
        {
            if(!region.empty())
            {
                clientConfig.region = region;
            }
            else
            {
                clientConfig.region = Aws::Region::AP_NORTHEAST_1;
            }

            this->s3Client = std::make_shared<Aws::S3::S3Client>(cred, clientConfig, Aws::Client::AWSAuthV4Signer::PayloadSigningPolicy::Never, false);
        }

        this->createBucketIfNotExists = createBucketIfNotExists;

        this->initialized = true;
        return 0;
    }

    void S3Storage::finalize()
    {
        std::cout << "S3Storage::finalize()" << std::endl;
        // 既存のファイル一覧や進行中のダウンロードは消す
        this->waitAllTask();

        std::lock_guard<std::recursive_mutex> lk(this->mutexSdk);

        this->s3Client.reset();

        return;
    }

    void S3Storage::setCallback(const DownloadResult& callback)
    {
        std::lock_guard<std::recursive_mutex> lk(this->mutexSdk);
        this->callback = callback;
    }

    void S3Storage::setDirPath(const std::string& path)
    {
        // 既存のファイル一覧や進行中のダウンロードは消す
        std::lock_guard<std::recursive_mutex> lk(this->mutexSdk);
        this->waitAllTask();
        this->completeItems.clear();
        this->items.clear();

        std::size_t pos;
        if((pos=path.find("/")) != std::string::npos)
        {
            this->bucketName = path.substr(0, pos);
            this->prefix = path.substr(pos+1);
            std::cout << "bucket:" << this->bucketName << " prefix:" << this->prefix << std::endl;
        }
        else
        {
            this->bucketName = path;
            this->prefix.clear();
        }

        if(!this->s3Client)
        {
            return;
        }
        Aws::S3::Model::GetBucketAclRequest request;
        request.SetBucket(this->bucketName);
        Aws::S3::Model::GetBucketAclOutcome outcome = this->s3Client->GetBucketAcl(request);
        if (outcome.IsSuccess())
        {
            std::cout << "GetBucketAcl() success" << std::endl;
            this->bucketExist = true;
        }
        else
        {
            if(outcome.GetError().GetErrorType() == Aws::S3::S3Errors::NO_SUCH_BUCKET)
            {
                std::cout << "no such bucket!" << std::endl;
            }
            else
            {
                std::cout << "unrecoverable error" << std::endl;
            }
            std::cout << outcome.GetError().GetMessage() << std::endl;
        }
    }

    void S3Storage::setFilePath(const std::string& path)
    {
        // 既存のファイル一覧や進行中のダウンロードは消す
        std::lock_guard<std::recursive_mutex> lk(this->mutexSdk);
        this->waitAllTask();
        this->completeItems.clear();
        this->items.clear();

        // ファイルの実在確認はどうするか?
        std::size_t pos;
        if((pos=path.find("/")) != std::string::npos)
        {
            this->bucketName = path.substr(0, pos);
            this->prefix.clear();
            this->items.push_back(std::make_shared<StorageItem>(this->bucketName+"/"+path.substr(pos+1)));
            std::cout << "bucket:" << this->bucketName << " file:" << this->items[0]->getPath() << std::endl;
        }
        else
        {
            // error
            this->bucketName = path;
            this->prefix.clear();
        }

        if(!this->s3Client)
        {
            return;
        }
        Aws::S3::Model::GetBucketAclRequest request;
        request.SetBucket(this->bucketName);
        Aws::S3::Model::GetBucketAclOutcome outcome = this->s3Client->GetBucketAcl(request);
        if (outcome.IsSuccess())
        {
            std::cout << "GetBucketAcl() success" << std::endl;
            this->bucketExist = true;
        }
        else
        {
            if(outcome.GetError().GetErrorType() == Aws::S3::S3Errors::NO_SUCH_BUCKET)
            {
                std::cout << "no such bucket!" << std::endl;
            }
            else
            {
                std::cout << "unrecoverable error" << std::endl;
            }
            std::cout << outcome.GetError().GetMessage() << std::endl;
        }
    }

    std::string S3Storage::getBucket()
    {
        return this->bucketName;
    }

    std::vector<std::shared_ptr<StorageItem>> S3Storage::getFiles()
    {
        std::lock_guard<std::recursive_mutex> lk(this->mutexSdk);

        if(!this->items.empty())
        {
            return this->items;
        }
        
        if(this->bucketName.empty())
        {
            return this->items;
        }

        if(!this->s3Client)
        {
            return this->items;
        }
    
        std::cout << "search: " << this->bucketName << std::endl;

        Aws::S3::Model::ListObjectsRequest request;
        request.SetBucket(this->bucketName);
        if(!this->prefix.empty())
        {
            request.SetPrefix(this->prefix);
        }        

        auto outcome = this->s3Client->ListObjects(request);

        if (outcome.IsSuccess())
        {
            std::cout << "Objects in bucket '" << this->bucketName << "':" << std::endl;
            
            Aws::Vector<Aws::S3::Model::Object> objects = outcome.GetResult().GetContents();
            
            this->items.reserve(objects.size());
            for (Aws::S3::Model::Object& object : objects)
            {
                std::cout << object.GetKey() << std::endl;
                std::string path;
                if(!this->bucketName.empty())
                {
                    path += this->bucketName+"/";
                }
                path += object.GetKey();
                this->items.push_back(std::make_shared<StorageItem>(path));
            }
        }
        else
        {
            std::cout << "Error: ListObjects: " << outcome.GetError().GetMessage() << std::endl;
        }

        return this->items;        
    }

    void S3Storage::requestDownload(const std::shared_ptr<StorageItem>& target)
    {
        auto result = std::find(this->items.begin(), this->items.end(), target);
        if(result==this->items.end())
        {
            std::cout << "target not found" << std::endl;
        }
        else
        {
            std::cout << "target found " << result-this->items.begin() << std::endl;
            (*result)->requestDownload();
        }
        this->refreshDownloadTask();
        return;
    }

    std::shared_ptr<StorageItem> S3Storage::getAnyOne()
    {
        // 起こされるまで待つ
        // 起きたらreturnQueueを確認、ひとつ取得して返す
        // ひとつも無かったらまた待つ
        std::unique_lock<std::recursive_mutex> lk(this->mutexInstanceMembers);
        this->condInstanceMembers.wait(lk, [this]{
            if(this->returnQueue.empty())
            {
                if(this->items.size()<=this->completeItems.size())
                {
                    // 全て完了している
                    return true;
                }
                else
                {
                    // 完了してるアイテムがまだ少ない
                    return false;
                }
            }
            else
            {
                // 何か完了した
                return true;
            }
        });
        if(this->returnQueue.empty())
        {
            return std::shared_ptr<StorageItem>();
        }
        else
        {
            auto completeItem = this->returnQueue.front();
            this->returnQueue.pop();
            std::cout << "notify complete \"" << completeItem->getPath() << "\"" << std::endl;
            return completeItem;
        }
    }

    std::shared_ptr<StorageItem> S3Storage::get(int pos)
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

    void S3Storage::putItem(std::shared_ptr<StorageItem> item)
    {
        std::cout << "putItem() object:" << item->getPath() << " size:" << item->getSize() << std::endl;
        if(!this->bucketExist)
        {
            if(this->createBucketIfNotExists)
            {
                Aws::S3::Model::CreateBucketRequest request;
                request.SetBucket(this->bucketName);
                auto outcome = this->s3Client->CreateBucket(request);
                if(outcome.IsSuccess())
                {
                    std::cout << "CreateBucket : " << this->bucketName << std::endl;
                    this->bucketExist = true;
                }
                else
                {
                    auto err = outcome.GetError();
                    std::cout << "Error: CreateBucket: " << this->bucketName << " : " << err.GetExceptionName() << ": " << err.GetMessage() << std::endl;
                }
            }
            else
            {
                std::cout << "Error: Bucket not exists : " << this->bucketName << std::endl;
            }
        }

        auto body = std::shared_ptr<Aws::IOStream>(new boost::interprocess::bufferstream(static_cast<char*>(item->getRawData()), item->getSize()));

        Aws::S3::Model::PutObjectRequest objectRequest;
        objectRequest.SetBucket(this->bucketName);
        std::size_t offset = 0;
        if(!this->bucketName.empty())
        {
            offset += this->bucketName.length() + 1;
        }
        auto path = item->getPath();
        path.erase(0, offset);
        objectRequest.SetKey(path);
        objectRequest.SetBody(body);

        Aws::S3::Model::PutObjectOutcome outcome = this->s3Client->PutObject(objectRequest);
        if(outcome.IsSuccess())
        {
            std::cout << "putItem() success" << std::endl;
        }
        else
        {
            std::cout << "putItem() error" << std::endl;
        }

        return;
    }

    void S3Storage::waitAllTask()
    {
        std::cout << "S3Storage::waitAllTask()" << std::endl;
        // 新規のダウンロードタスクを追加できない状態にして
        // 進行中のタスクの完了を待つ(現状キャンセルをサポートしていないので)
        // 全itemのstatusを確認してみる。クラス変数の進行数を見ても良いはず。
        std::unique_lock<std::recursive_mutex> lk(this->mutexInstanceMembers);
        this->condInstanceMembers.wait(lk, [this]{
            bool inProgress = false;
            for(auto item : this->items)
            {
                if(StorageItem::ItemState::inProgress == item->getState())
                {
                    inProgress = true;
                }
            }
            return !inProgress;
        });

        return;
    }

    void S3Storage::refreshDownloadTask()
    {
        // itemsの中からrequestedなitemを探す
        // 進行数が上限以下ならダウンロード開始して進行数を増やす
        // 上限に達していれば何もしないで返す
        // 
        // 完了コールバックの中でする事
        // itemのバッファにコンテンツを格納する
        // 対象itemのstateをcompleteまたはfailedに変更する
        // 対象itemをreturnQueueに追加する(参照のコピー)
        // 進行数を減らす
        // getAnyOne()でブロックしてる人がいたら起こしてあげる(複数いたら全員。起こされたらqueueから取り出してもらって、既に空ならまた待ってもらう。)

        // std::lockでまとめるべき?
        std::lock_guard<std::recursive_mutex> lkClass(S3Storage::mutexClassMembers);
        std::lock_guard<std::recursive_mutex> lkInstance(this->mutexInstanceMembers);
        for(auto item : this->items)
        {
            if(item->getState() == StorageItem::ItemState::requested)
            {
                if(Storage::maxConcurrent > Storage::inProgress)
                {
                    item->startDownload();
                    Storage::inProgress++;
                    
                    std::size_t offset = 0;
                    if(!this->bucketName.empty())
                    {
                        offset += this->bucketName.length() + 1;
                    }
                    auto path = item->getPath();
                    path.erase(0, offset);
                    std::cout << "item path     : " << item->getPath() << std::endl;
                    std::cout << "download path : " << path << std::endl;

                    Aws::S3::Model::GetObjectRequest objectRequest;
                    objectRequest.SetBucket(this->bucketName);
                    objectRequest.SetKey(path);
                    Aws::S3::Model::GetObjectOutcome getObjectOutcome = this->s3Client->GetObject(objectRequest);
                    
                    std::shared_ptr<Aws::Client::AsyncCallerContext> context = Aws::MakeShared<Aws::Client::AsyncCallerContext>("GetObjectAllocationTag");
                    context->SetUUID(path);
                    
                    //std::mutex download_mutex;
                    //std::condition_variable download_variable;
                    //std::unique_lock<std::mutex> lock(download_mutex);

                    std::cout << "start download " << Storage::inProgress << std::endl;
                    this->s3Client->GetObjectAsync(
                        objectRequest,
                        [this, item](const Aws::S3::S3Client* s3client, const Aws::S3::Model::GetObjectRequest& request, const Aws::S3::Model::GetObjectOutcome& outcome, const std::shared_ptr<const Aws::Client::AsyncCallerContext>& context)
                        {
                            {
                                std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);

                                Aws::S3::Model::GetObjectOutcome& outcomeTemp = const_cast<Aws::S3::Model::GetObjectOutcome&>(outcome);
                                if(outcomeTemp.IsSuccess())
                                {
                                    item->completeDownload(true);
                                    std::cout << "download complete " << Storage::inProgress-1 << std::endl;
                                    auto& retrieved_file = outcomeTemp.GetResultWithOwnership().GetBody();
                                    
                                    std::vector<unsigned char> buffer(std::istreambuf_iterator<char>(retrieved_file), {});
                                    std::cout << "object:" << item->getPath() << " size:" << buffer.size() << std::endl;
                                    item->setRawData(&buffer[0], buffer.size());
                                }
                                else
                                {
                                    item->completeDownload(false, outcomeTemp.GetError().GetMessage());
                                    std::cout << "failed to download " << item->getPath() << " by " << outcomeTemp.GetError().GetMessage() << std::endl;
                                }

                                this->completeItems.push_back(item);
                                this->returnQueue.push(item);
                                Storage::inProgress--;
                                this->condInstanceMembers.notify_all();
                            }
                            this->refreshDownloadTask();
                        },
                        context);
                }
            }

        }
    }

}
