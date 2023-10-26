#include <iostream>
#include <string.h>

#include "storage.hpp"

namespace ObjStorageFdw
{
    StorageItem::StorageItem(const std::string& path):
    state(StorageItem::ItemState::partial),
    body(nullptr),
    errorMessage("no information"),
    rawSize(0),
    rawBuffer(nullptr),
    additionalData(nullptr)
    {
        this->path = path;
    }

    StorageItem::~StorageItem()
    {
        if(nullptr!=this->rawBuffer)
        {
            delete this->rawBuffer;
        }
    }

    void StorageItem::requestDownload()
    {
        if(this->state == StorageItem::ItemState::partial)
        {
            this->state = StorageItem::ItemState::requested;
        }
        return;
    }

    void StorageItem::startDownload()
    {
        if(this->state == StorageItem::ItemState::requested)
        {
            this->state = StorageItem::ItemState::inProgress;
        }
        return;
    }

    void StorageItem::completeDownload(bool success, const std::string& errorMessage)
    {
        if(this->state == StorageItem::ItemState::inProgress)
        {
            if(success)
            {
                this->state = StorageItem::ItemState::complete;
            }
            else
            {
                this->state = StorageItem::ItemState::failed;
            }
        }
        if(!errorMessage.empty())
        {
            this->errorMessage = errorMessage;
        }
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

    std::string& StorageItem::getPath()
    {
        return this->path;
    }

    void StorageItem::setStream(std::iostream& body)
    {
        //this->body = body;
        std::string lineBuf;
        while(std::getline(body, lineBuf))
        {
            std::cout << lineBuf << std::endl;
        }
    }

/*
    void StorageItem::addLine(const std::string& line)
    {
        this->lines.push_back(line);
    }

    const std::vector<std::string>& StorageItem::getLines()
    {
        return this->lines;
    }
*/

    void StorageItem::setRawData(void* buffer, int size)
    {
        if(this->rawBuffer!=nullptr)
        {
            delete this->rawBuffer;
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
        std::cout << "inc ref " << this->refCount << std::endl;
        return this->refCount;
    }

    int Storage::decRef()
    {
        this->refCount--;
        std::cout << "dec ref " << this->refCount << std::endl;
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
}
