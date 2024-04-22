//
// prepareTestStorage <targetServer> <connection options>
//
// targetServer
//

#include "localStorage.hpp"
#include "azureStorage.hpp"
#include "s3Storage.hpp"
#include "gcpStorage.hpp"
#include <aws/core/Aws.h>

#include <memory>

int main(int argc, char* argv[])
{
    auto aws_sdk_options = Aws::SDKOptions();
	Aws::InitAPI(aws_sdk_options);

    if(argc<4)
    {
        std::cout << "need more options" << std::endl;
        std::cout << "usage: <schema> <source dir> <target dir> <connection options>" << std::endl;
        return -1;
    }
    std::string schema = argv[1];
    std::string sourceDir = argv[2];
    std::string distDir = argv[3];

    if(!sourceDir.empty())
    {
        if('/'!=sourceDir.back())
        {
            sourceDir = sourceDir + '/';
        }
    }

    auto srcStorage = ObjStorageFdw::LocalStorage::GetInstance(0);
    srcStorage->initialize();
    srcStorage->setDirPath(sourceDir);
    for(const auto& item : srcStorage->getFiles())
    {
        srcStorage->requestDownload(item);
    }

    std::shared_ptr<ObjStorageFdw::Storage> distStorage;
    if(schema=="local")
    {
        distStorage = ObjStorageFdw::LocalStorage::GetInstance(1);
        std::dynamic_pointer_cast<ObjStorageFdw::LocalStorage>(distStorage)->initialize();
        distStorage->setDirPath(distDir);
    }
#ifdef SUPPORT_AZURE
    else if(schema=="azure")
    {
        if(argc<5)
        {
            std::cout << "need more options" << std::endl;
            std::cout << "usage: azure <source dir> <target dir> <connection options>" << std::endl;
            return -1;
        }
        distStorage = ObjStorageFdw::AzureStorage::GetInstance(1);
        std::dynamic_pointer_cast<ObjStorageFdw::AzureStorage>(distStorage)->initialize(argv[4], argv[5], argv[6], true);
        distStorage->setDirPath(distDir);
    }
#endif
#ifdef SUPPORT_S3
    else if(schema=="s3")
    {
        if(argc<7)
        {
            std::cout << "need more options" << std::endl;
            std::cout << "usage: s3 <source dir> <target dir> <access key id> <secret key> <region or endpoint url>" << std::endl;
            return -1;
        }
        distStorage = ObjStorageFdw::S3Storage::GetInstance(1);
        if(0==strncmp(argv[6], "http", 4))
        {
            std::dynamic_pointer_cast<ObjStorageFdw::S3Storage>(distStorage)->initialize(argv[4], argv[5], "", argv[6], true);
        }
        else
        {
            std::dynamic_pointer_cast<ObjStorageFdw::S3Storage>(distStorage)->initialize(argv[4], argv[5], argv[6], "", true);
        }
        distStorage->setDirPath(distDir);
    }
#endif
#ifdef SUPPORT_GCS
    else if(schema=="gcs")
    {
        if(argc<5)
        {
            std::cout << "need more options" << std::endl;
            std::cout << "usage: gcs <source dir> <target dir> <rest endpoint url>" << std::endl;
            return -1;
        }
        distStorage = ObjStorageFdw::GcpStorage::GetInstance(1);
        std::dynamic_pointer_cast<ObjStorageFdw::GcpStorage>(distStorage)->initialize(argv[4], true, true, (char *)"objstorage_fdw");
        distStorage->setDirPath(distDir);
    }
#endif
    else
    {
        std::cout << "unknown schema" << std::endl;
        return -1;
    }

    while(true)
    {
        const auto& localFile = srcStorage->getAnyOne();
        if(!localFile)
        {
            break;
        }

        std::cout << localFile->getPath() << std::endl;
        std::cout << localFile->getPath().substr(sourceDir.length()) << std::endl;
        std::cout << distDir << "/" << localFile->getPath().substr(sourceDir.length()) << std::endl;

        auto uploadItem = std::make_shared<ObjStorageFdw::StorageItem>(distDir+"/"+localFile->getPath().substr(sourceDir.length()));
        uploadItem->requestDownload();
        uploadItem->startDownload();
        uploadItem->setRawData(localFile->getRawData(), localFile->getSize());
        uploadItem->completeDownload(false);

        distStorage->putItem(uploadItem);
    }

    distStorage->finalize();
    srcStorage->finalize();

    Aws::ShutdownAPI(aws_sdk_options);
}
