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
        virtual std::shared_ptr<StorageItem> addFilePath(const std::string& path) override;
        virtual std::vector<std::shared_ptr<StorageItem>> getFiles() override;
        virtual void requestDownload(const std::shared_ptr<StorageItem>& target) override;
        std::shared_ptr<StorageItem> getAnyOne(bool missing_ok = false) override;
        std::shared_ptr<StorageItem> get(size_t pos, bool missing_ok = false) override;
        std::shared_ptr<StorageItem> getByPath(std::string path, bool missing_ok = false) override;
        virtual void putItem(std::shared_ptr<StorageItem> item) override;
        virtual void waitAllTask() override;
        virtual bool requestDelete(std::string target, std::string format, bool is_dir) override;
        virtual ~LocalStorage();
    private:
        virtual bool is_file_exist(std::string path) override;
        std::vector<std::shared_ptr<StorageItem>> getDirFiles(const std::string& path);
        std::string dirPath;
    };
}
