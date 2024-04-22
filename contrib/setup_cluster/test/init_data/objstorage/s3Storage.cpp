#include "s3Storage.hpp"
#include <aws/s3/model/PutObjectRequest.h>
#include <aws/s3/model/GetBucketAclRequest.h>
#include <aws/s3/model/CreateBucketRequest.h>
#include <aws/s3/model/DeleteObjectRequest.h>
#include <aws/s3/model/HeadObjectRequest.h>
#include <boost/interprocess/streams/bufferstream.hpp>
#include <aws/core/client/DefaultRetryStrategy.h>

namespace ObjStorageFdw
{
    std::shared_ptr<S3Storage> S3Storage::GetInstance(unsigned int id)
    {
        if (Storage::instancePool.find(id) == Storage::instancePool.end())
        {
            Storage::instancePool.insert(std::make_pair(id, std::make_shared<S3Storage>(id)));
        }
        else if (!std::dynamic_pointer_cast<S3Storage>(Storage::instancePool.at(id)))
        {
            throw std::runtime_error("exist Storage instance but different type " + std::to_string(id));
        }

        return std::dynamic_pointer_cast<S3Storage>(Storage::instancePool.at(id));
    }

    S3Storage::S3Storage(unsigned int id)
    :Storage(id),
    bucketName(std::string()),
    createBucketIfNotExists(false),
    bucketExist(false),
    prefix(std::string())
    {

        return;
    }

    S3Storage::~S3Storage()
    {
        this->finalize();
    }

    int S3Storage::initialize(const std::string& accessKeyId, const std::string& secretKey, const std::string& region, const std::string& endpoint, const bool createBucketIfNotExists, const bool suppressRetry)
    {
        std::lock_guard<std::recursive_mutex> lk(this->mutexSdk);

        if (this->initialized)
            return -1;

        if (accessKeyId.empty())
            throw std::runtime_error("S3Storage: accessKeyId is needed");

        if (secretKey.empty())
            throw std::runtime_error("S3Storage: secretKey is needed");

        Aws::Client::ClientConfiguration clientConfig;
        auto cred = Aws::Auth::AWSCredentials(accessKeyId, secretKey);

        if (suppressRetry)
        {
            clientConfig.retryStrategy = std::make_shared<Aws::Client::DefaultRetryStrategy>(2, 2);
        }

        if (!endpoint.empty())
        {
            clientConfig.scheme = Aws::Http::Scheme::HTTP;
            clientConfig.endpointOverride = endpoint;

            this->s3Client = std::make_shared<Aws::S3::S3Client>(cred, clientConfig, Aws::Client::AWSAuthV4Signer::PayloadSigningPolicy::Never, false);
        }
        else
        {
            if (!region.empty())
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
        // 既存のファイル一覧や進行中のダウンロードは消す
        this->waitAllTask();

        std::lock_guard<std::recursive_mutex> lk(this->mutexSdk);

        this->s3Client.reset();
        /* clean target object information */
        this->bucketName.clear();
        this->prefix.clear();

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
        if ((pos=path.find("/")) != std::string::npos)
        {
            this->bucketName = path.substr(0, pos);
            this->prefix = path.substr(pos+1);
        }
        else
        {
            this->bucketName = path;
            this->prefix.clear();
        }

        if (!this->s3Client)
        {
            return;
        }
        Aws::S3::Model::GetBucketAclRequest request;
        request.SetBucket(this->bucketName);
        Aws::S3::Model::GetBucketAclOutcome outcome = this->s3Client->GetBucketAcl(request);
        if (outcome.IsSuccess())
        {
            this->bucketExist = true;
        }
        else
        {
            this->bucketExist = false;
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
        if ((pos=path.find("/")) != std::string::npos)
        {
            this->bucketName = path.substr(0, pos);
            this->prefix.clear();
            this->items.push_back(std::make_shared<StorageItem>(this->bucketName + "/" + path.substr(pos+1)));
        }
        else
        {
            // error
            this->bucketName = path;
            this->prefix.clear();
        }

        if (!this->s3Client)
        {
            return;
        }
        Aws::S3::Model::GetBucketAclRequest request;
        request.SetBucket(this->bucketName);
        Aws::S3::Model::GetBucketAclOutcome outcome = this->s3Client->GetBucketAcl(request);
        if (outcome.IsSuccess())
        {
            this->bucketExist = true;
        }
        else
        {
            throw std::runtime_error(outcome.GetError().GetMessage());
        }
    }

    std::shared_ptr<StorageItem> S3Storage::addFilePath(const std::string& path)
    {
        std::lock_guard<std::recursive_mutex> lk(this->mutexSdk);
        std::lock_guard<std::recursive_mutex> lk2(this->mutexInstanceMembers);

        // ファイルの実在確認はどうするか?
        size_t pos;
        if ((pos = path.find("/")) != std::string::npos)
        {
            this->bucketName = path.substr(0, pos);
            this->prefix.clear();
            this->items.push_back(std::make_shared<StorageItem>(this->bucketName + "/" + path.substr(pos+1)));
        }
        else
        {
            throw std::runtime_error("Illegal file path: " + path);
        }

        if (!this->s3Client)
            throw std::runtime_error("s3Client empty");

        Aws::S3::Model::GetBucketAclRequest request;
        request.SetBucket(this->bucketName);
        Aws::S3::Model::GetBucketAclOutcome outcome = this->s3Client->GetBucketAcl(request);
        if (outcome.IsSuccess())
        {
            this->bucketExist = true;
        }
        else
        {
            throw std::runtime_error(outcome.GetError().GetMessage());
        }

        return this->items.back();
    }


    std::string S3Storage::getBucket()
    {
        return this->bucketName;
    }

    std::vector<std::shared_ptr<StorageItem>> S3Storage::getFiles()
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

        if (!this->s3Client)
        {
            return this->items;
        }

        Aws::S3::Model::ListObjectsRequest request;
        request.SetBucket(this->bucketName);
        if (!this->prefix.empty())
        {
            request.SetPrefix(this->prefix);
        }

        auto outcome = this->s3Client->ListObjects(request);

        if (outcome.IsSuccess())
        {
            Aws::Vector<Aws::S3::Model::Object> objects = outcome.GetResult().GetContents();
            this->items.reserve(objects.size());

            for (Aws::S3::Model::Object& object : objects)
            {
                std::string path;
                if (!this->bucketName.empty())
                {
                    path += this->bucketName+"/";
                }
                path += object.GetKey();
                this->items.push_back(std::make_shared<StorageItem>(path));
            }
        }
        else
        {
            throw std::runtime_error(outcome.GetError().GetMessage());
        }

        return this->items;
    }

    void S3Storage::requestDownload(const std::shared_ptr<StorageItem>& target)
    {
        auto result = std::find(this->items.begin(), this->items.end(), target);
        if (result == this->items.end())
        {
            throw std::runtime_error("S3Storage requestDownload: target not found");
        }
        else
        {
            (*result)->requestDownload();
        }
        this->refreshDownloadTask();
        return;
    }

    void S3Storage::putItem(std::shared_ptr<StorageItem> item)
    {
        if (!this->bucketExist)
        {
            if (this->createBucketIfNotExists)
            {
                Aws::S3::Model::CreateBucketRequest request;
                request.SetBucket(this->bucketName);
                auto outcome = this->s3Client->CreateBucket(request);
                if (outcome.IsSuccess())
                {
                    this->bucketExist = true;
                }
                else
                {
                    auto err = outcome.GetError();
                    throw std::runtime_error("Error: CreateBucket: " + this->bucketName + " : " + err.GetExceptionName() + ": " + err.GetMessage());
                }
            }
            else
            {
                throw std::runtime_error("Bucket does not exists : " + this->bucketName);
            }
        }

        auto body = std::shared_ptr<Aws::IOStream>(new boost::interprocess::bufferstream(static_cast<char*>(item->getRawData()), item->getSize()));

        Aws::S3::Model::PutObjectRequest objectRequest;
        objectRequest.SetBucket(this->bucketName);
        std::size_t offset = 0;
        if (!this->bucketName.empty())
        {
            offset += this->bucketName.length() + 1;
        }
        auto path = item->getPath();
        path.erase(0, offset);
        objectRequest.SetKey(path);
        objectRequest.SetBody(body);

        Aws::S3::Model::PutObjectOutcome outcome = this->s3Client->PutObject(objectRequest);
        if (!outcome.IsSuccess())
        {
            throw std::runtime_error("putItem() error: " + outcome.GetError().GetMessage());
        }

        return;
    }

    void S3Storage::waitAllTask()
    {
        // 新規のダウンロードタスクを追加できない状態にして
        // 進行中のタスクの完了を待つ(現状キャンセルをサポートしていないので)
        // 全itemのstatusを確認してみる。クラス変数の進行数を見ても良いはず。
        std::unique_lock<std::recursive_mutex> lk(this->mutexInstanceMembers);
        this->condInstanceMembers.wait(lk, [this]{
            bool inProgress = false;
            for (auto item : this->items)
            {
                if (StorageItem::ItemState::inProgress == item->getState())
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

        for (auto item : this->items)
        {
            if (item->getState() == StorageItem::ItemState::requested)
            {
                if (Storage::maxConcurrent > Storage::inProgress)
                {
                    item->startDownload();
                    Storage::inProgress++;
                    std::size_t offset = 0;

                    if (!this->bucketName.empty())
                    {
                        offset += this->bucketName.length() + 1;
                    }

                    auto path = item->getPath();
                    path.erase(0, offset);

                    Aws::S3::Model::GetObjectRequest objectRequest;
                    objectRequest.SetBucket(this->bucketName);
                    objectRequest.SetKey(path);
                    Aws::S3::Model::GetObjectOutcome getObjectOutcome = this->s3Client->GetObject(objectRequest);
                    std::shared_ptr<Aws::Client::AsyncCallerContext> context = Aws::MakeShared<Aws::Client::AsyncCallerContext>("GetObjectAllocationTag");
                    context->SetUUID(path);

                    this->s3Client->GetObjectAsync(
                        objectRequest,
                        [this, item](const Aws::S3::S3Client* s3client, const Aws::S3::Model::GetObjectRequest& request, const Aws::S3::Model::GetObjectOutcome& outcome, const std::shared_ptr<const Aws::Client::AsyncCallerContext>& context)
                        {
                            {
                                std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
                                Aws::S3::Model::GetObjectOutcome& outcomeTemp = const_cast<Aws::S3::Model::GetObjectOutcome&>(outcome);

                                if (outcomeTemp.IsSuccess())
                                {
                                    auto& retrieved_file = outcomeTemp.GetResultWithOwnership().GetBody();
                                    std::vector<unsigned char> buffer(std::istreambuf_iterator<char>(retrieved_file), {});
                                    item->setRawData(&buffer[0], buffer.size());
                                    item->completeDownload(true);
                                }
                                else
                                {
                                    item->completeDownload(false, outcomeTemp.GetError().GetMessage(), outcomeTemp.GetError().GetErrorType() == Aws::S3::S3Errors::NO_SUCH_KEY);
                                }

                                this->completeItems.push_back(item);
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

    /*
     * Check single file exist in S3
     */
    bool S3Storage::is_file_exist(std::string path)
    {
        Aws::S3::Model::HeadObjectRequest request;
        request.WithBucket(this->bucketName)
            .WithKey(SplitBucketPath(path).second);

        auto outcome = this->s3Client->HeadObject(request);

        if (outcome.IsSuccess())
        {
            return true;   
        }
        else
        {
            if (outcome.GetError().GetErrorType() == Aws::S3::S3Errors::NO_SUCH_KEY 
                || outcome.GetError().GetErrorType() == Aws::S3::S3Errors::RESOURCE_NOT_FOUND)
            {
                return false;
            }
            else
            {
                throw std::runtime_error("Get Error: " + outcome.GetError().GetMessage());
            }
        }
    }

    /*
     *  Try to delete file/folder in S3
     */
    bool S3Storage::requestDelete(std::string item, std::string format, bool is_dir)
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
                Aws::S3::Model::DeleteObjectRequest  request;
                Aws::S3::Model::DeleteObjectOutcome  outcome;

                request.WithKey(p.second).WithBucket(this->bucketName);
                outcome = this->s3Client->DeleteObject(request);

                if (!outcome.IsSuccess())
                {
                    if (outcome.GetError().GetErrorType() == Aws::S3::S3Errors::NO_SUCH_KEY 
                        || outcome.GetError().GetErrorType() == Aws::S3::S3Errors::RESOURCE_NOT_FOUND)
                    {
                        return false;
                    }
                    else
                    {
                        throw std::runtime_error("Get Error: " + outcome.GetError().GetMessage());
                    }
                }
            }

            this->items.clear();
            this->completeItems.clear();
        }
        else 
        {

            auto p = SplitBucketPath(item);
            Aws::S3::Model::DeleteObjectRequest  request;
            Aws::S3::Model::DeleteObjectOutcome  outcome;

            request.WithKey(p.second).WithBucket(this->bucketName);
            outcome = this->s3Client->DeleteObject(request);

            if (!outcome.IsSuccess())
            {
                if (outcome.GetError().GetErrorType() == Aws::S3::S3Errors::NO_SUCH_KEY 
                    || outcome.GetError().GetErrorType() == Aws::S3::S3Errors::RESOURCE_NOT_FOUND)
                {
                    return false;
                }
                else
                {
                    throw std::runtime_error("Get Error: " + outcome.GetError().GetMessage());
                }
            }
            
            this->items.clear();
            this->completeItems.clear();
        }
        return true;
    }
}
