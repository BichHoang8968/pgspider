#pragma once

#include "storage.hpp"

#include <thread>
#include <condition_variable>

#include "google/cloud/storage/client.h"

namespace ObjStorageFdw
{
    class GcpStorage : public Storage
    {
    public:
        static std::shared_ptr<GcpStorage> GetInstance(unsigned int id);
        GcpStorage(unsigned int id);
        virtual int initialize(const std::string& restEndpoint, const bool& createBucketIfNotExists=false);
        virtual void finalize() override;
        virtual void setDirPath(const std::string& path) override;
        virtual void setFilePath(const std::string& path) override;
        virtual std::vector<std::shared_ptr<StorageItem>> getFiles() override;
        virtual void requestDownload(const std::shared_ptr<StorageItem>& target) override;
        virtual std::shared_ptr<StorageItem> getAnyOne() override;
        virtual std::shared_ptr<StorageItem> get(int pos) override;
        virtual void putItem(std::shared_ptr<StorageItem> item) override;
        virtual void waitAllTask() override;
        virtual ~GcpStorage();
    private:
        std::recursive_mutex mutexSdk;
        google::cloud::storage::Client client;
        std::string restEndpoint;
        std::string bucketName;
        bool createBucketIfNotExists;
        bool bucketExist;
        std::string pathPrefix;

        std::recursive_mutex mutexInstanceMembers;
        std::condition_variable_any condInstanceMembers;
        std::vector<std::shared_ptr<StorageItem>> items;
        std::vector<std::shared_ptr<StorageItem>> completeItems;

        std::vector<std::thread> downloadWorkers;
        std::queue<std::shared_ptr<StorageItem>> downloadTasks;
        std::recursive_mutex mutexDownloadQueue;
        std::condition_variable_any condWorkers;
        bool stop;
    };

}