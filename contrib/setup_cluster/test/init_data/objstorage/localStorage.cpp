#include "localStorage.hpp"
#include <algorithm>
#include <fstream>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <dirent.h>
#include <stdio.h>
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>

namespace ObjStorageFdw
{

    /**
     * @brief check whether given directory existed or not
     *
     * @param path directory path
     * @return true if directory path existed
     */
    bool
    is_dir_exist(const std::string& path)
    {
        struct stat info;
        if (stat(path.c_str(), &info) != 0)
        {
            return false;
        }
        return (info.st_mode & S_IFDIR) != 0;
    }


    /**
     * @brief remove recursively directory (files and subdirectories)
     *
     * @param path
     * @return true if success
     */
    bool
    delete_folder_tree(std::string path, std::string format)
    {
        int         ret;
        struct stat st;
        DIR        *dp;
        struct dirent *entry;
        std::string dirname = path;

        ret = stat(path.c_str(), &st);
        if (ret != 0)
        {
            return false;
        }
            

        dp = opendir(path.c_str());
        if (!dp)
        {
            return false;
        }


        /* remove redundant slash */
        auto back = dirname.begin() + dirname.length();
        while (*--back == '/')
        {
            *back = '\0';
        }

        entry = readdir(dp);
        while (entry != NULL) {
            char *newpath = new char[1024];
            if (strcmp(entry->d_name, ".") != 0 && strcmp(entry->d_name, "..") != 0)
            {
                sprintf(newpath, "%s/%s", dirname.c_str(), entry->d_name);
                if (is_dir_exist(newpath))
                {
                    if ( !delete_folder_tree(newpath, format) )
                    {
                        delete[] newpath;
                        closedir(dp);
                        return false;
                    }
                }
                else
                {
                    // if (str_has_suffix(newpath, format))
                        std::remove(newpath);
                }
                delete[] newpath;
            }
            entry = readdir(dp);
        }
        closedir(dp);
        rmdir(path.c_str());
        return true;
    }


    std::shared_ptr<LocalStorage> LocalStorage::GetInstance(unsigned int id)
    {
        if (Storage::instancePool.find(id) == Storage::instancePool.end())
        {
            Storage::instancePool.insert(std::make_pair(id, std::make_shared<LocalStorage>(id)));
        }
        else if (!std::dynamic_pointer_cast<LocalStorage>(Storage::instancePool.at(id)))
        {
            throw std::runtime_error("[ERROR] exist Storage instance but different type ");
        }
        return std::dynamic_pointer_cast<LocalStorage>(Storage::instancePool.at(id));
    }

    LocalStorage::LocalStorage(unsigned int id)
    :Storage(id)
    {
    }

    LocalStorage::~LocalStorage()
    {
        this->finalize();
    }

    int LocalStorage::initialize()
    {
        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
        if (this->initialized)
        {
            // already initialized
            return -1;
        }
        this->initialized = true;
        return 0;
    }

    void LocalStorage::finalize()
    {
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
        if (!path.empty())
        {
            if ('/' == path.back())
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

    std::shared_ptr<StorageItem> LocalStorage::addFilePath(const std::string& path)
    {
        std::lock_guard<std::recursive_mutex> lk(this->mutexInstanceMembers);
        this->waitAllTask();
        this->items.push_back(std::make_shared<StorageItem>(path));

        return this->items.back();
    }

    std::vector<std::shared_ptr<StorageItem>> LocalStorage::getDirFiles(const std::string& dirPath)
    {
        DIR* dir;
        struct dirent *dent;

        dir = opendir(dirPath.c_str());
        if (NULL==dir)
        {
            return this->items;
        }
        while((dent=readdir(dir)) != NULL)
        {
            if ((dent->d_type==DT_REG)||(dent->d_type==DT_LNK))
            {
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

        if (!this->items.empty())
        {
            return this->items;
        }

        if (this->dirPath.empty())
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
        if (result==this->items.end())
        {
            throw std::runtime_error("target not found");
        }
        else
        {
            (*result)->requestDownload();
        }
        return;
    }

    std::shared_ptr<StorageItem> LocalStorage::getAnyOne(bool missing_ok)
    {
        std::unique_lock<std::recursive_mutex> lk(this->mutexInstanceMembers);
        for (auto item : this->items)
        {
            if (item->getState() == StorageItem::ItemState::requested)
            {
                item->startDownload();

                std::ifstream ifs(item->getPath(), std::ios::binary);

                if (!ifs)
                {
                    if (missing_ok)
                        item->completeDownload(false, "No such item", true);
                    else
                        throw std::runtime_error("No such item");
                    continue;
                }

                ifs.seekg(0, std::ios::end);
                std::streampos size = ifs.tellg();
                ifs.seekg(0);

                char* data = new char[size];
                ifs.read(data, size);
                ifs.close();
                item->setRawData(data, size);
                delete[] data;

                item->completeDownload(true);
                this->completeItems.push_back(item);
                return item;
            }
        }
        // "There is no available item"
        std::shared_ptr<StorageItem> nullItem;
        return nullItem;
    }

    std::shared_ptr<StorageItem> LocalStorage::get(size_t pos, bool missing_ok)
    {
        if (pos >= this->items.size())
        {
            if (missing_ok)
                return nullptr;
            else
                throw std::runtime_error("Index " + std::to_string(pos) + " out of range, index must smaller than " + std::to_string(this->items.size()));
        }

        auto item = this->items[pos];

        if (item->getState() == StorageItem::ItemState::requested)
        {
            item->startDownload();

            std::ifstream ifs(item->getPath(), std::ios::binary);

            if (!ifs)
            {
                if (missing_ok)
                {
                    item->completeDownload(false, "No such item", true);
                    this->completeItems.push_back(item);
                    return item;
                }
                else
                    throw std::runtime_error("No such item");
            }
            else
            {
                ifs.seekg(0, std::ios::end);
                std::streampos size = ifs.tellg();
                ifs.seekg(0);

                char* data = new char[size];
                ifs.read(data, size);
                ifs.close();
                item->setRawData(data, size);
                delete[] data;

                item->completeDownload(true);
                this->completeItems.push_back(item);
                return item;
            }
        }

        return item;
    }

    std::shared_ptr<StorageItem> LocalStorage::getByPath(std::string path, bool missing_ok)
    {
        for (auto item : this->items)
        {
            if (item->getPath() != path)
                continue;

            if (item->getState() == StorageItem::ItemState::requested)
            {
                item->startDownload();

                std::ifstream ifs(item->getPath(), std::ios::binary);

                if (!ifs)
                {
                    if (missing_ok)
                    {
                        item->completeDownload(false, "No such item", true);
                        this->completeItems.push_back(item);
                        return item;
                    }
                    else
                        throw std::runtime_error("No such item");
                    }
                else
                {
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

            return item;
        }

        if (missing_ok)
            return nullptr;
        else
            throw std::runtime_error("No such item");
    }

    /*
     * Create single dir if not exist
    */
    void _create_dir_recursive(std::string path) {
        if (path == "/" || path == "") return;

        auto slashIter = path.find_last_of("/");
        if(slashIter != std::string::npos) {
            auto parent = path.substr(0, slashIter);
            _create_dir_recursive(parent);
        }
        if(mkdir(path.c_str(), S_IRWXU | S_IRWXG | S_IROTH) && errno != EEXIST)
            throw std::runtime_error("Error while trying to create " + path + " " + std::string(strerror(errno))); 
    }

    /*
     * Create single dir if not exist
    */
    void create_mkdir(std::string path) {
        auto slashIter = path.find_last_of("/");
        if(slashIter != std::string::npos) { 
            auto topDir = path.substr(0, slashIter);
            _create_dir_recursive(topDir);
        }
    }

    void LocalStorage::putItem(std::shared_ptr<StorageItem> item)
    {
        /* Create dir if not exist */
        create_mkdir(item->getPath());

        std::ofstream ofs(item->getPath(), std::ios::out | std::ios::binary);
        ofs.write((const char*)item->getRawData(), item->getSize());
        ofs.close();

        return;
    }

    /*
     *  Try to delete file/folder in Local
     */
    bool LocalStorage::requestDelete(std::string target, std::string format, bool is_dir)
    {
        
        if( is_dir )
        {
            if( !delete_folder_tree(target.c_str(), format) ) 
            {
                return false;
            }
            this->completeItems.clear();
            this->items.clear();
        }
        else
        {
            /* Remove items from compelete list*/
            if( remove(target.c_str()) != 0 ) 
            {
                return false;
            }

            this->items.clear();
            this->completeItems.clear();
        }

        return true;
    }

    void LocalStorage::waitAllTask()
    {
        /* Nothing to do, there is no background worker for local storage */
        return;
    }

    /*
     * Check single file exist
     */
    bool LocalStorage::is_file_exist(std::string path)
    {
        struct stat buffer;   
        return (stat (path.c_str(), &buffer) == 0);
    }
    
}
