#include "localStorage.hpp"
#include <algorithm>
#include <iostream>
#include <fstream>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <dirent.h>

namespace ObjStorageFdw
{
    std::shared_ptr<LocalStorage> LocalStorage::GetInstance(unsigned int id)
    {
        if (Storage::instancePool.find(id) == Storage::instancePool.end())
        {
            std::cout << "create new LocalStorage instance " << id << std::endl;
            Storage::instancePool.insert(std::make_pair(id, std::make_shared<LocalStorage>(id)));
        }
        else if(!std::dynamic_pointer_cast<LocalStorage>(Storage::instancePool.at(id)))
        {
            std::cout << "[ERROR] exist Storage instance but different type " << id << std::endl;
            return std::shared_ptr<LocalStorage>();
        }
        std::cout << "return existing LocalStorage instance " << id << std::endl;
        return std::dynamic_pointer_cast<LocalStorage>(Storage::instancePool.at(id));
    }

    LocalStorage::LocalStorage(unsigned int id)
    :Storage(id)
    {
    }

    LocalStorage::~LocalStorage()
    {
        std::cout << "LocalStorage::~LocalStorage() " << this->id << std::endl;
        this->finalize();
    }

    int LocalStorage::initialize()
    {
        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
        if(this->initialized)
        {
            std::cout << "already initialized" << std::endl;
            return -1;
        }
        this->initialized = true;
        return 0;
    }

    void LocalStorage::finalize()
    {
        std::cout << "LocalStorage::finalize()" << std::endl;
        // 既存のファイル一覧や進行中のダウンロードは消す
        this->waitAllTask();

        return;
    }

    void LocalStorage::setDirPath(const std::string& path)
    {
        // 既存のファイル一覧や進行中のダウンロードは消す
        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
        this->waitAllTask();
        this->completeItems.clear();
        this->items.clear();

        this->dirPath = path;
        if(!path.empty())
        {
            if('/' == path.back())
            {
                this->dirPath = path.substr(0, path.size()-1);
            }
            else
            {
                this->dirPath = path;
            }
        }
    }

    void LocalStorage::setFilePath(const std::string& path)
    {
        // 既存のファイル一覧や進行中のダウンロードは消す
        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
        this->waitAllTask();
        this->completeItems.clear();
        this->items.clear();

        this->dirPath.clear();
        this->items.push_back(std::make_shared<StorageItem>(path));
        // ファイルの実在確認はどうするか?
    }

    std::vector<std::shared_ptr<StorageItem>> LocalStorage::getDirFiles(const std::string& dirPath)
    {
        std::cout << "search: " << dirPath << std::endl;
        DIR* dir;
        struct dirent *dent;

        dir = opendir(dirPath.c_str());
        if(NULL==dir)
        {
            return this->items;
        }
        while((dent=readdir(dir)) != NULL)
        {
            if((dent->d_type==DT_REG)||(dent->d_type==DT_LNK))
            {
                std::cout << dent->d_name << std::endl;
                // dir名の追加、/を含むかどうか確認しなければ
                this->items.push_back(std::make_shared<StorageItem>(dirPath+"/"+std::string(dent->d_name)));
            }
            else
            {
              std::string path = dirPath+"/"+std::string(dent->d_name);
              struct stat info;
              if (stat(path.c_str(), &info) != 0)
              {
                // stat error, temporarily ignore
                continue;
              }
              if (S_ISDIR(info.st_mode))
              {
                if (!strcmp(".", dent->d_name) || !strcmp("..", dent->d_name))
                  continue;
                this->getDirFiles(path);
              }
            }
        }
        closedir(dir);
        return this->items;
    }

    std::vector<std::shared_ptr<StorageItem>> LocalStorage::getFiles()
    {
        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);

        if(!this->items.empty())
        {
            return this->items;
        }

        if(this->dirPath.empty())
        {
            return this->items;
        }

        this->getDirFiles(this->dirPath);

        return this->items;        
    }

    void LocalStorage::requestDownload(const std::shared_ptr<StorageItem>& target)
    {
        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);

        auto result = std::find(this->items.begin(), this->items.end(), target);
        if(result==this->items.end())
        {
            std::cout << "target not found" << std::endl;
        }
        else
        {
            //std::cout << "target found " << result-this->items.begin() << std::endl;
            (*result)->requestDownload();
        }
        //this->refreshDownloadTask();
        return;
    }

    std::shared_ptr<StorageItem> LocalStorage::getAnyOne()
    {
        std::cout << "items " << this->items.size() << std::endl;
        std::unique_lock<std::recursive_mutex> lk(this->mutexInstanceMembers);
        for(auto item : this->items)
        {
            if(item->getState() == StorageItem::ItemState::requested)
            {
                item->startDownload();

                std::ifstream ifs(item->getPath(), std::ios::binary);

                if (!ifs)
                {
                    std::cout << "No such item => skip item" << std::endl;
                    item->completeDownload(false);
                    continue;
                }

                ifs.seekg(0, std::ios::end);
                std::streampos size = ifs.tellg();
                ifs.seekg(0);

                char* data = new char[size];
                ifs.read(data, size);
                ifs.close();
                item->setRawData(data, size);
                delete data;

                item->completeDownload(true);
                this->completeItems.push_back(item);
                return item;
            }
        }
        std::cout << "There is no available item" << std::endl;
        std::shared_ptr<StorageItem> nullItem;
        return nullItem;
    }

    std::shared_ptr<StorageItem> LocalStorage::get(int pos)
    {
        std::cout << "items " << this->items.size() << " completeItems " << this->completeItems.size() << std::endl;
        std::unique_lock<std::recursive_mutex> lk(this->mutexInstanceMembers);

        if(pos<this->completeItems.size())
        {
            return this->completeItems[pos];
        }
        else if(pos<this->items.size())
        {
            std::cout << "not found downloaded item" << std::endl;
            std::shared_ptr<StorageItem> nullItem;
            return nullItem;
        }
        else
        {
            std::cout << "out of range" << std::endl;
            std::shared_ptr<StorageItem> nullItem;
            return nullItem;
        }

    }

    void LocalStorage::putItem(std::shared_ptr<StorageItem> item)
    {
        std::ofstream ofs(item->getPath(), std::ios::out | std::ios::binary);
        ofs.write((const char*)item->getRawData(), item->getSize());
        ofs.close();

        return;
    }

    void LocalStorage::waitAllTask()
    {
        std::cout << "LocalStorage::waitAllTask()" << std::endl;
        // 新規のダウンロードタスクを追加できない状態にして
        // 進行中のタスクの完了を待つ(現状キャンセルをサポートしていないので)
        // 全itemのstatusを確認してみる。クラス変数の進行数を見ても良いはず。
        //std::unique_lock<std::recursive_mutex> lk(this->mutexInstanceMembers);
        //this->condInstanceMembers.wait(lk, [this]{
        //    bool inProgress = false;
        //    for(auto item : this->items)
        //    {
        //        if(StorageItem::ItemState::inProgress == item->getState())
        //        {
        //            inProgress = true;
        //        }
        //    }
        //    return !inProgress;
        //});

        return;
    }
}
