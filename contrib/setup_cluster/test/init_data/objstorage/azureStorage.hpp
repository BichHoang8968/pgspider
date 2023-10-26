#pragma once

#include "storage.hpp"

#include <thread>
#include <condition_variable>

#include <azure/core.hpp>
#include <azure/storage/blobs.hpp>

namespace ObjStorageFdw
{
    class AzureStorage : public Storage
    {
    public:
        static std::shared_ptr<AzureStorage> GetInstance(unsigned int id);
        AzureStorage(unsigned int id);
        virtual int initialize(const std::string& connectionString, const bool& createContainerIfNotExists=false);
        virtual void finalize() override;
        virtual void setCallback(const DownloadResult& callback);
        virtual void setDirPath(const std::string& path) override;
        virtual void setFilePath(const std::string& path) override;
        virtual std::vector<std::shared_ptr<StorageItem>> getFiles() override;
        virtual void requestDownload(const std::shared_ptr<StorageItem>& target) override;
        virtual std::shared_ptr<StorageItem> getAnyOne() override;
        virtual std::shared_ptr<StorageItem> get(int pos) override;
        virtual void putItem(std::shared_ptr<StorageItem> item) override;
        virtual void waitAllTask() override;
        virtual ~AzureStorage();
    private:
        std::recursive_mutex mutexSdk;
        std::string connectionString;
        std::string containerName;
        std::string pathPrefix;
        bool createContainerIfNotExists;

        std::recursive_mutex mutexInstanceMembers;
        std::condition_variable_any condInstanceMembers;
        std::vector<std::shared_ptr<StorageItem>> items;
        std::vector<std::shared_ptr<StorageItem>> completeItems;
        //std::unique_ptr<Azure::Storage::Blobs::BlobContainerClient> containerClient;
        Azure::Storage::Blobs::BlobContainerClient containerClient;

        std::vector<std::thread> downloadWorkers;
        std::queue<std::shared_ptr<StorageItem>> downloadTasks;
        std::recursive_mutex mutexDownloadQueue;
        std::condition_variable_any condWorkers;
        bool stop;
    };

}