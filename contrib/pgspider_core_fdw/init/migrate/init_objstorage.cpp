#include <string>
#include <azure/core.hpp>
#include <azure/storage/blobs.hpp>
#include <google/cloud/storage/client.h>
#include <aws/core/Aws.h>
#include <aws/core/auth/AWSCredentialsProvider.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/CreateBucketRequest.h>
#include <iostream>

std::string bucket = "data";
using namespace Azure::Storage::Blobs;
using namespace std;


void createAzure(string connect,string bucket)
{
    auto containerClient = BlobContainerClient::CreateFromConnectionString(connect, bucket);
    containerClient.CreateIfNotExists();
}

void createGcs(string connect, string bucket)
{
    auto options = ::google::cloud::Options();
    options.set<::google::cloud::storage::RestEndpointOption>(connect);
    options.set<::google::cloud::UnifiedCredentialsOption>(::google::cloud::MakeInsecureCredentials());
    options.set<::google::cloud::storage::ProjectIdOption>("objstorage_fdw");
    options.set<::google::cloud::storage::DownloadStallTimeoutOption>(std::chrono::seconds(1));
    options.set<::google::cloud::storage::RetryPolicyOption>(::google::cloud::storage::LimitedErrorCountRetryPolicy(1).clone());

    auto gclient = ::google::cloud::storage::Client(options);
    auto metadata = gclient.CreateBucket(bucket, ::google::cloud::storage::BucketMetadata());
    if (!metadata)
    {
        throw std::runtime_error(std::move(metadata).status().message());
    }
}

void createS3(string connect, string bucket, string accesskey, string secret)
{
    Aws::Client::ClientConfiguration clientConfig;
    auto cred = Aws::Auth::AWSCredentials(accesskey, secret);
    clientConfig.scheme = Aws::Http::Scheme::HTTP;
    clientConfig.endpointOverride = connect;
    auto s3Client = std::make_shared<Aws::S3::S3Client>(cred, clientConfig, Aws::Client::AWSAuthV4Signer::PayloadSigningPolicy::Never, false);
    Aws::S3::Model::CreateBucketRequest request;
    request.SetBucket(bucket);
    auto outcome = s3Client->CreateBucket(request);
    if (!outcome.IsSuccess())
    {
        auto err = outcome.GetError();
        throw std::runtime_error("Error: CreateBucket: " + bucket + " : " + err.GetExceptionName() + ": " + err.GetMessage());
    }
}

int main() {

    auto aws_sdk_options = new Aws::SDKOptions();
	Aws::InitAPI(*aws_sdk_options);

    cout << "Create bucket for azure" << endl;
    createAzure("DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10000/devstoreaccount1;", bucket);
    createAzure("DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10010/devstoreaccount1;", bucket);

    cout << "Create bucket for gcs" << endl;
    createGcs("http://127.0.0.1:4443", bucket);
    createGcs("http://127.0.0.1:4453", bucket);

    cout << "Create bucket for s3" << endl;

    createS3("http://127.0.0.1:9000", bucket, "minioadmin", "minioadmin");
    createS3("http://127.0.0.1:9010", bucket, "minioadmin", "minioadmin");

    Aws::ShutdownAPI(*aws_sdk_options);
    aws_sdk_options = NULL;
}
