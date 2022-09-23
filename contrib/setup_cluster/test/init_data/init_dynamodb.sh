#!/bin/sh
export AWS_ACCESS_KEY_ID='admin'
export AWS_SECRET_ACCESS_KEY='testadmin'
export AWS_REGION='us-east-1'

DYNAMODB_ENDPOINT="http://localhost:8000"

# Below commands must be run in DynamoDB to create databases used in regression tests with `admin` user and `testadmin` password.
# aws configure
# -- AWS Access Key ID : admin
# -- AWS Secret Access Key : testadmin
# -- Default region name [None]: us-west-2

aws dynamodb delete-table --table-name tbl_dynamodb --endpoint-url $DYNAMODB_ENDPOINT

aws dynamodb --endpoint-url $DYNAMODB_ENDPOINT \
        create-table --table-name tbl_dynamodb \
        --attribute-definitions AttributeName=c1,AttributeType=S AttributeName=c2,AttributeType=N \
        --key-schema AttributeName=c1,KeyType=HASH AttributeName=c2,KeyType=RANGE \
        --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1

aws dynamodb --endpoint-url $DYNAMODB_ENDPOINT put-item --table-name tbl_dynamodb --item $'{"c1":{"S":"Dynamodb"}, "c2":{"N":"-2091322"}, "c3":{"N":"-2563.21514"}}'
aws dynamodb --endpoint-url $DYNAMODB_ENDPOINT put-item --table-name tbl_dynamodb --item $'{"c1":{"S":"Caichao"}, "c2":{"N":"25452"}, "c3":{"N":"332.8"}}'
aws dynamodb --endpoint-url $DYNAMODB_ENDPOINT put-item --table-name tbl_dynamodb --item $'{"c1":{"S":"simple"}, "c2":{"N":"989839"}, "c3":{"N":"54562563.21514"}}'
aws dynamodb --endpoint-url $DYNAMODB_ENDPOINT put-item --table-name tbl_dynamodb --item $'{"c1":{"S":"nothing"}, "c2":{"N":"-9892"}, "c3":{"N":"8657.2"}}'
aws dynamodb --endpoint-url $DYNAMODB_ENDPOINT put-item --table-name tbl_dynamodb --item $'{"c1":{"S":"0YJ_gG7l000"}, "c2":{"N":"1222"}, "c3":{"N":"-2563.21514"}}'
