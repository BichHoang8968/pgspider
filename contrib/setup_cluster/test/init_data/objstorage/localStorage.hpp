#pragma once

#include "storage.hpp"

namespace ObjStorageFdw
{
    class LocalStorage : public Storage
    {
    public:
        static std::shared_ptr<LocalStorage> GetInstance(unsigned int id);
        LocalStorage(unsigned int id);
        virtual int initialize();
        virtual void finalize() override;
        virtual void setDirPath(const std::string& path) override;
        virtual void setFilePath(const std::string& path) override;
        virtual std::vector<std::shared_ptr<StorageItem>> getFiles() override;
        virtual void requestDownload(const std::shared_ptr<StorageItem>& target) override;
        virtual std::shared_ptr<StorageItem> getAnyOne() override;
        virtual std::shared_ptr<StorageItem> get(int pos) override;
        virtual void putItem(std::shared_ptr<StorageItem> item) override;
        virtual void waitAllTask() override;
        virtual ~LocalStorage();
    private:
        std::vector<std::shared_ptr<StorageItem>> getDirFiles(const std::string& path);
        std::recursive_mutex mutexInstanceMembers;
        std::vector<std::shared_ptr<StorageItem>> items;
        std::vector<std::shared_ptr<StorageItem>> completeItems;
        std::string dirPath;
    };
}
