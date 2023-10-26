#pragma once

#include <iostream>
#include <functional>
#include <vector>
#include <queue>
#include <map>
#include <string>
#include <memory>
#include <mutex>

namespace ObjStorageFdw
{
    class StorageItem;
    //class Storage;
    //class S3Storage;
    //class LocalStorage;

    using DownloadResult = std::function<void(const std::shared_ptr<StorageItem> item, bool success)>;

    class StorageItem
    {
    public:
        enum class ItemState{partial, requested, inProgress, complete, failed, unknown};
        StorageItem(const std::string& path);
        ~StorageItem();
        void requestDownload();
        void startDownload();
        void completeDownload(bool success, const std::string& errorMessage = "");
        const std::string& getErrorMessage();
        bool isFilled();
        ItemState getState();
        void setState(const ItemState& state);
        std::string& getPath();
        void setStream(std::iostream& body);
//        void addLine(const std::string& lineBuf);
//        const std::vector<std::string>& getLines();
        void setRawData(void* buffer, int size);
        int getSize();
        void* getRawData();
        void setAddition(void* pointer);
        void* getAddition();
    private:
        std::string path; // S3だとkey
//        std::shared_ptr<std::vector<unsigned char>> data;
        int rawSize;
        unsigned char* rawBuffer;
        ItemState state;
        std::string errorMessage;
        std::iostream body;
//        std::vector<std::string> lines;
        void* additionalData;
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
        virtual std::vector<std::shared_ptr<StorageItem>> getFiles() = 0;
        virtual void requestDownload(const std::shared_ptr<StorageItem>& target) = 0;
        virtual std::shared_ptr<StorageItem> getAnyOne() = 0;
        virtual std::shared_ptr<StorageItem> get(int pos) = 0;
        virtual void putItem(std::shared_ptr<StorageItem> item) = 0;
        virtual void waitAllTask() = 0;
        virtual ~Storage();
    protected:
        static std::recursive_mutex mutexClassMembers;
        static std::map<unsigned int, std::shared_ptr<Storage>> instancePool;
        static int inProgress;
        static int maxConcurrent;
        unsigned int id;
        int refCount;
        bool initialized;
    };
}