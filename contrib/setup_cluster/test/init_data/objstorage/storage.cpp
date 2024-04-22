#include <string.h>

#include "storage.hpp"

namespace ObjStorageFdw
{

    /*
    * Split s3,gcp path into bucket name and file path.
    * return pair with bucket name and file path.
    */
    std::pair<std::string, std::string>
    SplitBucketPath(std::string path)
    {
        auto first_blackslash = path.find('/');
        if (first_blackslash == std::string::npos)
        {
            throw std::runtime_error(std::string("objstorage_fdw: invalid s3 path. " + path));
        }

        std::string bucket = path.substr(0, first_blackslash);
        std::string file_path = path.substr(first_blackslash +1);

        return std::pair<std::string, std::string>(bucket, file_path);
    }

    bool str_has_suffix(const std::string &str, const std::string &suffix)
    {
        std::string lower = str;
        for(auto& c : lower)
        {
            c = tolower(c);
        }

        return lower.size() >= suffix.size() &&
            lower.compare(lower.size() - suffix.size(), suffix.size(), suffix) == 0;
    }

    StorageItem::StorageItem(const std::string& path):
    state(StorageItem::ItemState::partial),
    errorMessage("no information"),
    rawSize(0),
    rawBuffer(nullptr),
    additionalData(nullptr),
    request_upload(false)
    {
        this->path = path;
    }

    StorageItem::~StorageItem()
    {
        if (nullptr!=this->rawBuffer)
        {
            delete this->rawBuffer;
        }
    }

    void StorageItem::requestDownload()
    {
        if (this->state == StorageItem::ItemState::partial)
        {
            this->state = StorageItem::ItemState::requested;
        }
        return;
    }

    void StorageItem::startDownload()
    {
        if (this->state == StorageItem::ItemState::requested)
        {
            this->state = StorageItem::ItemState::inProgress;
        }
        return;
    }

    void StorageItem::completeDownload(bool success, const std::string& errorMessage, bool not_found)
    {
        if (this->state == StorageItem::ItemState::inProgress)
        {
            if (success)
            {
                this->state = StorageItem::ItemState::complete;
            }
            else
            {
                this->state = StorageItem::ItemState::failed;
            }
        }
        if (!errorMessage.empty())
        {
            this->errorMessage = errorMessage;
        }
        this->not_found = not_found;
        return;
    }

    const std::string& StorageItem::getErrorMessage()
    {
        return this->errorMessage;
    }

    void StorageItem::setState(const StorageItem::ItemState& state)
    {
        this->state = state;
    }

    StorageItem::ItemState StorageItem::getState()
    {
        return this->state;
    }

    bool StorageItem::isExisted()
    {
        return !this->not_found;
    }

    void StorageItem::requestUpload()
    {
        this->request_upload = true;
    }

    bool StorageItem::isNeedUpload()
    {
        return this->request_upload;
    }

    std::string& StorageItem::getPath()
    {
        return this->path;
    }

    void StorageItem::setRawData(void* buffer, int size)
    {
        if (this->rawBuffer!=nullptr)
        {
            delete[] this->rawBuffer;
        }
        this->rawBuffer = new uint8_t[size];
        this->rawSize = size;
        memcpy(this->rawBuffer, buffer, size);
    }

    void* StorageItem::getRawData()
    {
        return this->rawBuffer;
    }

    int StorageItem::getSize()
    {
        return this->rawSize;
    }

    void StorageItem::setAddition(void* pointer)
    {
        this->additionalData = pointer;
    }

    void* StorageItem::getAddition()
    {
        return this->additionalData;
    }

    std::recursive_mutex Storage::mutexClassMembers;
    int Storage::inProgress = 0;
    int Storage::maxConcurrent = 1;

    void Storage::setMaxConcurrent(const int& maxConcurrent)
    {
        std::lock_guard<std::recursive_mutex> lk(Storage::mutexClassMembers);
        Storage::maxConcurrent = maxConcurrent;
    }

    int Storage::getMaxConcurrent()
    {
        return Storage::maxConcurrent;
    }

    Storage::Storage(unsigned int id)
    :id(id),
    refCount(0),
    initialized(false)
    {
    }

    unsigned int Storage::getId()
    {
        return this->id;
    }

    int Storage::incRef()
    {
        this->refCount++;
        return this->refCount;
    }

    int Storage::decRef()
    {
        this->refCount--;
        return this->refCount;
    }

    bool Storage::isInitialized()
    {
        return this->initialized;
    }

    std::map<unsigned int, std::shared_ptr<Storage>> Storage::instancePool;
    void Storage::DeleteInstance(unsigned int id)
    {
        if (Storage::instancePool.find(id) != Storage::instancePool.end())
        {
            Storage::instancePool.erase(id);
        }

        return;
    }

    Storage::~Storage()
    {
    }

    std::shared_ptr<StorageItem>
    Storage::getAnyOne(bool missing_ok)
    {
        std::unique_lock<std::recursive_mutex> lk(this->mutexInstanceMembers);
        size_t targetNum = 0; /* first downloaded file */

        this->condInstanceMembers.wait(lk, [this, targetNum]
        {
            if (this->completeItems.size() >= this->items.size())
            {
                /* All target file have been downloaded */
                return true;
            }
            if (targetNum >= this->completeItems.size())
            {
                /* Target file has not been downloaded */
                return false;
            }
            /* Download completed */
            return true;
        });

        if (targetNum < this->completeItems.size())
        {
            auto item = this->completeItems[targetNum];

            if (item->getState() == StorageItem::ItemState::complete)
            {
                return item;
            }
            else
            {
                if (!item->isExisted() && missing_ok)
                    return nullptr;
                else
                    throw std::runtime_error(item->getErrorMessage());
            }
        }

        return nullptr;
    }

    size_t
    Storage::getRequestedNum()
    {
        size_t res = 0;

        for (auto item: this->items)
        {
            if (item->getState() > StorageItem::ItemState::partial
                && item->getState() != StorageItem::ItemState::failed)
                res++;
        }

        return res;
    }

    std::shared_ptr<StorageItem>
    Storage::get(size_t pos, bool missing_ok)
    {
        /*
         * When modifying a foreign table, the target file may not have been
         * requested to download before (when INSERT), so check the total number of
         * downloaded files, by the status of each item to avoid endless waiting.
         *
         * if 'pos' not small than total file -> return null immediately
         */
        auto req = getRequestedNum();
        if (req <= pos)
            return nullptr;

        std::unique_lock<std::recursive_mutex> lk(this->mutexInstanceMembers);

        this->condInstanceMembers.wait(lk, [this, pos]
        {
            if (this->completeItems.size() >= this->items.size())
            {
                /* All target file have been downloaded */
                return true;
            }
            if (pos >= this->completeItems.size())
            {
                /* Target file has not been downloaded */
                return false;
            }
            /* Download completed */
            return true;
        });

        if (pos < this->completeItems.size())
        {
            auto item = this->completeItems[pos];

            if (item->getState() == StorageItem::ItemState::complete)
            {
                return item;
            }
            else if (item->getState() == StorageItem::ItemState::failed)
            {
                if (!item->isExisted() && missing_ok)
                    return nullptr;
                else
                    throw std::runtime_error(item->getErrorMessage());
            }
            else
                throw std::runtime_error("unexpected item state " + std::to_string((int) item->getState()));
        }

        return nullptr;
    }

    std::shared_ptr<StorageItem>
    Storage::getByPath(std::string path, bool missing_ok)
    {
        std::unique_lock<std::recursive_mutex> lk(this->mutexInstanceMembers);

        this->condInstanceMembers.wait(lk, [this, path]
        {
            if (this->completeItems.size() >= this->items.size())
            {
                /* All target file have been downloaded */
                return true;
            }

            for (auto item : this->completeItems)
            {
                /* found path */
                if (item->getPath() == path)
                {
                    return true;
                }
            }

            return false;
        });

        for (auto item : this->completeItems)
        {
            /* found path */
            if (item->getPath() == path)
            {
                if (item->getState() == StorageItem::ItemState::complete)
                {
                    return item;
                }
                else if (item->getState() == StorageItem::ItemState::failed)
                {
                    if (!item->isExisted() && missing_ok)
                        return item;
                    else
                        throw std::runtime_error(item->getErrorMessage());
                }
                else
                    throw std::runtime_error("unexpected item state " + std::to_string((int) item->getState()));
            }
        }

        /* not found */
        if (missing_ok)
            return nullptr;

        throw std::runtime_error("File path does not exist: " + path);
    }

    std::string
    get_parent(std::string path)
    {
        return path;
    }

    /*
     * Check if directory or file exist in storage
     */
    bool
    Storage::isExist(std::string path, std::string format)
    {
        bool is_exist = false;
        if(format.empty())
        {
            return is_file_exist(path);
        }
        else
        {
            auto items = this->getFiles();
            int itemCount = items.size();

            if (itemCount == 0) {
                is_exist = false;
            }
            for(int i=0; i<itemCount; i++)
            {
                auto item = items[i];
                if(item != nullptr)
                {
                    auto itemPath = item->getPath();
                    if( str_has_suffix(itemPath, format) )
                    {
                        is_exist = true;
                        break;
                    }
                }
            }
        }


        return is_exist;
    }
}
