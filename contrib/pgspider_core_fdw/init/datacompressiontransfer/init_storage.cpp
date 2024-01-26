#include <string>
#include <aws/core/Aws.h>
#include <aws/core/auth/AWSCredentialsProvider.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/CreateBucketRequest.h>
#include <iostream>

using namespace std;

void createS3(string connect, string bucket, string accesskey, string secret);

int main()
{
    std::string bucket = "bucket";

    /* create bucket for MinIO/S3 */
    auto aws_sdk_options = new Aws::SDKOptions();
    Aws::InitAPI(*aws_sdk_options);
    createS3("http://127.0.0.1:9000", bucket, "minioadmin", "minioadmin");
    createS3("http://127.0.0.1:9001", bucket, "minioadmin", "minioadmin");
    createS3("http://127.0.0.1:9002", bucket, "minioadmin", "minioadmin");
    Aws::ShutdownAPI(*aws_sdk_options);
    aws_sdk_options = NULL;
}

/**
 * create bucket for s3 (minio)
 */
void
createS3(string connect, string bucket, string accesskey, string secret)
{
    Aws::Client::ClientConfiguration clientConfig;
    clientConfig.scheme = Aws::Http::Scheme::HTTP;
    clientConfig.endpointOverride = connect;

    auto cred = Aws::Auth::AWSCredentials(accesskey, secret);
    auto s3Client = std::make_shared<Aws::S3::S3Client>(cred, clientConfig, Aws::Client::AWSAuthV4Signer::PayloadSigningPolicy::Never, false);

    Aws::S3::Model::CreateBucketRequest request;
    request.SetBucket(bucket);

    auto outcome = s3Client->CreateBucket(request);
    if (!outcome.IsSuccess())
    {
        auto err = outcome.GetError();
        cout << "Error: CreateBucket '" << bucket << "': " << err.GetExceptionName() << ": " << err.GetMessage() << endl;
        return;
    }

    cout << "Created s3 bucket: " << bucket << " on: " << connect << endl;
}
