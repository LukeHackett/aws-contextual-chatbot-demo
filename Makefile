# Directories
WORK_DIR = $(shell pwd)
CFN_DIR = $(WORK_DIR)/cloudformation
DATASET_DIR = $(WORK_DIR)/dataset

# AWS Variables
AWS_REGION = us-east-1
AWS_PROFILE = personal

# Application Variables
APP_NAME = chatbot-demo
APP_OPEN_SEARCH_STACK_NAME = $(APP_NAME)-open-search
APP_KNOWLEDGE_BASE_STACK_NAME = $(APP_NAME)-knowledge-base
APP_BEDROCK_AGENTS_STACK_NAME = $(APP_NAME)-bedrock-agents

APP_KNOWLEDGE_BASE_ID = $(shell aws cloudformation describe-stacks --stack-name $(APP_KNOWLEDGE_BASE_STACK_NAME) --query 'Stacks[0].Outputs[?OutputKey==`KnowledgeBaseId`].OutputValue' --output text --region $(AWS_REGION) --profile $(AWS_PROFILE))
APP_KNOWLEDGE_BASE_DATA_SOURCE_ID = $(shell aws cloudformation describe-stacks --stack-name $(APP_KNOWLEDGE_BASE_STACK_NAME) --query 'Stacks[0].Outputs[?OutputKey==`KnowledgeBaseDataSourceId`].OutputValue' --output text --region $(AWS_REGION) --profile $(AWS_PROFILE))

APP_S3_BUCKET_NAME = $(shell aws cloudformation describe-stacks --stack-name $(APP_KNOWLEDGE_BASE_STACK_NAME) --query 'Stacks[0].Outputs[?OutputKey==`ApplicationBucketName`].OutputValue' --output text --region $(AWS_REGION) --profile $(AWS_PROFILE))
APP_S3_BUCKET_KNOWLEDGE_SRC_DIR = $(shell aws cloudformation describe-stacks --stack-name $(APP_KNOWLEDGE_BASE_STACK_NAME) --query 'Stacks[0].Outputs[?OutputKey==`KnowledgeBaseS3Uri`].OutputValue' --output text --region $(AWS_REGION) --profile $(AWS_PROFILE))

APP_AGENT_ID = $(shell aws cloudformation describe-stacks --stack-name $(APP_BEDROCK_AGENTS_STACK_NAME) --query 'Stacks[0].Outputs[?OutputKey==`AgentId`].OutputValue' --output text --region $(AWS_REGION) --profile $(AWS_PROFILE))
APP_AGENT_VERSION = $(shell aws cloudformation describe-stacks --stack-name $(APP_BEDROCK_AGENTS_STACK_NAME) --query 'Stacks[0].Outputs[?OutputKey==`AgentVersion`].OutputValue' --output text --region $(AWS_REGION) --profile $(AWS_PROFILE))
APP_AGENT_LAMBDA = $(shell aws cloudformation describe-stacks --stack-name $(APP_BEDROCK_AGENTS_STACK_NAME) --query 'Stacks[0].Outputs[?OutputKey==`CreateAwsResourceLambdaArn`].OutputValue' --output text --region $(AWS_REGION) --profile $(AWS_PROFILE))


# from https://www.thapaliya.com/en/writings/well-documented-makefiles/
default: help
.PHONY: help
help:  ## Displays this help message
	awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Deployment

.PHONY: deploy-open-search
deploy-open-search:  ## Deploys the open search stack
	aws cloudformation deploy --template-file $(CFN_DIR)/01-open-search.yaml --stack-name $(APP_OPEN_SEARCH_STACK_NAME) --capabilities CAPABILITY_NAMED_IAM --region $(AWS_REGION) --profile $(AWS_PROFILE)

.PHONY: deploy-open-search-index
deploy-open-search-index:  ## Deploys the open search index
	echo "TBC..."
	# curl -XPUT "http://localhost:9200/bedrock-knowledge-base-default-index" -H 'Content-Type: application/json' 

.PHONY: deploy-knowledge-base
deploy-knowledge-base:  ## Deploys the knowledge base
	aws cloudformation deploy --template-file $(CFN_DIR)/03-knowledge-base.yaml --stack-name $(APP_KNOWLEDGE_BASE_STACK_NAME) --capabilities CAPABILITY_NAMED_IAM --region $(AWS_REGION) --profile $(AWS_PROFILE)

.PHONY: deploy-agents
deploy-agents:  ## Deploys the Bedrock Agents
	aws cloudformation deploy --template-file $(CFN_DIR)/04-bedrock-agents.yaml --stack-name $(APP_BEDROCK_AGENTS_STACK_NAME) --capabilities CAPABILITY_NAMED_IAM --region $(AWS_REGION) --profile $(AWS_PROFILE)

.PHONY: deploy-agents-group
deploy-agents-group:  ## Deploys the Bedrock Agent Group
	AGENT_ID=$(APP_AGENT_ID) AGENT_VERSION=$(APP_AGENT_VERSION) AGENT_LAMBDA=$(APP_AGENT_LAMBDA) envsubst < $(CFN_DIR)/05-bedrock-agents-group.json > /tmp/bedrock-agents-group.json
	aws bedrock-agent create-agent-action-group --cli-input-json file:///tmp/bedrock-agents-group.json --region $(AWS_REGION) --profile $(AWS_PROFILE)
	rm -rf /tmp/bedrock-agents-group.json

##@ Data

.PHONY: upload-dataset
upload-dataset:  ## Copies all data from the dataset directory into the knowledge base
	aws s3 cp $(DATASET_DIR) $(APP_S3_BUCKET_KNOWLEDGE_SRC_DIR) --recursive --region $(AWS_REGION) --profile $(AWS_PROFILE)
	aws bedrock-agent start-ingestion-job --knowledge-base-id $(APP_KNOWLEDGE_BASE_ID) --data-source-id $(APP_KNOWLEDGE_BASE_DATA_SOURCE_ID) --region $(AWS_REGION) --profile $(AWS_PROFILE)

.PHONY: clear-dataset
clear-dataset:  ## Removes all data from the S3 directory and the knowledge base
	aws s3 rm $(APP_S3_BUCKET_KNOWLEDGE_SRC_DIR) --recursive --region $(AWS_REGION) --profile $(AWS_PROFILE)
	aws bedrock-agent start-ingestion-job --knowledge-base-id $(APP_KNOWLEDGE_BASE_ID) --data-source-id $(APP_KNOWLEDGE_BASE_DATA_SOURCE_ID) --region $(AWS_REGION) --profile $(AWS_PROFILE)

.PHONY: clear-bucket
clear-bucket: clear-dataset  ## Removes all data from the S3 bucket
	aws s3 rm s3://$(APP_S3_BUCKET_NAME) --recursive --region $(AWS_REGION) --profile $(AWS_PROFILE)

##@ Cleanup

.PHONY: destroy-all
destroy-all:  ## Destroys all deployed resources
	aws cloudformation delete-stack --stack-name $(APP_BEDROCK_AGENTS_STACK_NAME) --region $(AWS_REGION) --profile $(AWS_PROFILE)
	aws cloudformation delete-stack --stack-name $(APP_KNOWLEDGE_BASE_STACK_NAME) --region $(AWS_REGION) --profile $(AWS_PROFILE)
	aws cloudformation delete-stack --stack-name $(APP_OPEN_SEARCH_STACK_NAME) --region $(AWS_REGION) --profile $(AWS_PROFILE)
