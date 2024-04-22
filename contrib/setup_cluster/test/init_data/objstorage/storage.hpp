#pragma once

#include <functional>
#include <vector>
#include <queue>
#include <map>
#include <string>
#include <memory>
#include <mutex>
#include <condition_variable>

namespace ObjStorageFdw
{
    class StorageItem;

    using DownloadResult = std::function<void(const std::shared_ptr<StorageItem> item, bool success)>;

    class StorageItem
    {
    public:
        enum class ItemState{partial, requested, inProgress, complete, failed};
        StorageItem(const std::string& path);
        ~StorageItem();
        void requestDownload();
        void startDownload();
        void completeDownload(bool success, const std::string& errorMessage = "", bool not_found = false);
        const std::string& getErrorMessage();
        ItemState getState();
        void setState(const ItemState& state);
        std::string& getPath();
        void setRawData(void* buffer, int size);
        int getSize();
        void* getRawData();
        void setAddition(void* pointer);
        void* getAddition();
        bool isExisted();
        void requestUpload();
        bool isNeedUpload();
    private:
        ItemState state;
        std::string errorMessage;
        int rawSize;
        unsigned char* rawBuffer;
        void* additionalData;
        std::string path; // S3だとkey
        bool not_found;
        bool request_upload;
    };

    class Storage
    {
    public:
        static void DeleteInstance(unsigned int id);

        void setMaxConcurrent(const int& maxConcurrent);
        int getMaxConcurrent();

        unsigned int getId();

        virtual int incRef();
        virtual int decRef();
        virtual bool isInitialized();

        Storage(unsigned int id);
        virtual void finalize() = 0;
        virtual void setDirPath(const std::string& path) = 0;
        virtual void setFilePath(const std::string& path) = 0;
        virtual std::shared_ptr<StorageItem> addFilePath(const std::string& path) = 0;
        virtual std::vector<std::shared_ptr<StorageItem>> getFiles() = 0;
        virtual void requestDownload(const std::shared_ptr<StorageItem>& target) = 0;
        virtual std::shared_ptr<StorageItem> getAnyOne(bool missing_ok = false);
        virtual std::shared_ptr<StorageItem> getByPath(std::string path, bool missing_ok = false);
        virtual std::shared_ptr<StorageItem> get(size_t pos, bool missing_ok = false);
        virtual void putItem(std::shared_ptr<StorageItem> item) = 0;
        virtual void waitAllTask() = 0;
        virtual bool requestDelete(std::string target, std::string format, bool is_dir) = 0;
        virtual bool isExist(std::string path, std::string format);
        virtual ~Storage();
    protected:
        size_t getRequestedNum();
        std::vector<std::shared_ptr<StorageItem>> items;
        std::vector<std::shared_ptr<StorageItem>> completeItems;
        static std::recursive_mutex mutexClassMembers;
        static std::map<unsigned int, std::shared_ptr<Storage>> instancePool;
        static int inProgress;
        static int maxConcurrent;
        unsigned int id;
        int refCount;
        bool initialized;
        std::recursive_mutex mutexInstanceMembers;
        std::condition_variable_any condInstanceMembers;
    private:
        virtual bool is_file_exist(std::string path) = 0;
    };

    bool str_has_suffix(const std::string &str, const std::string &suffix);
    std::pair<std::string, std::string> SplitBucketPath(std::string path);
}