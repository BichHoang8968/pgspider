#pragma once

#include "storage.hpp"

#include <aws/core/Aws.h>
#include <aws/core/auth/AWSCredentialsProvider.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/ListObjectsRequest.h>
#include <aws/s3/model/GetObjectRequest.h>
#include <aws/s3/model/Object.h>

namespace ObjStorageFdw
{
    class S3Storage : public Storage
    {
    public:
        static std::shared_ptr<S3Storage> GetInstance(unsigned int id);
        S3Storage(unsigned int id);

        // minioを使う時はendpointを指定する事。AWSを使う時はregionを指定する事。
        virtual int initialize(const std::string& accessKeyId, const std::string& secretKey, const std::string& region, const std::string& endpoint, const bool createBucketIfNotExists=false, const bool suppressRetry=false);
        virtual void finalize() override;
        virtual void setCallback(const DownloadResult& callback);
        virtual void setDirPath(const std::string& path) override;
        virtual void setFilePath(const std::string& path) override;
        virtual std::shared_ptr<StorageItem> addFilePath(const std::string& path) override;
        virtual std::string getBucket();
        virtual std::vector<std::shared_ptr<StorageItem>> getFiles() override;
        virtual void requestDownload(const std::shared_ptr<StorageItem>& target) override;
        virtual void putItem(std::shared_ptr<StorageItem> item) override;
        virtual bool requestDelete(std::string target, std::string format, bool is_dir) override;
        virtual void waitAllTask() override;
        virtual ~S3Storage();
    private:
        virtual bool is_file_exist(std::string path) override;
        std::recursive_mutex mutexSdk;
        std::shared_ptr<Aws::S3::S3Client> s3Client;
        std::string bucketName;
        bool createBucketIfNotExists;
        bool bucketExist;
        std::string prefix;

        DownloadResult callback;

        void refreshDownloadTask();
    };
}
