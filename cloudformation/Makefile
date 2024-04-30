# Directories
WORK_DIR = $(shell pwd)

# AWS Variables
AWS_REGION = us-east-1
AWS_PROFILE = personal
AWS_STACK_NAME = chatbot-demo

# from https://suva.sh/posts/well-documented-makefiles/
default: help
.PHONY: help
help:  ## Displays this help message
	awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: deploy-open-search
deploy-open-search:
	aws cloudformation deploy --template-file $(WORK_DIR)/01-open-search.yaml --stack-name $(AWS_STACK_NAME)-open-search --capabilities CAPABILITY_NAMED_IAM --region $(AWS_REGION) --profile $(AWS_PROFILE)

.PHONY: deploy-open-search-index
deploy-open-search-index:
	echo "TBC..."
	# curl -XPUT "http://localhost:9200/bedrock-knowledge-base-default-index" -H 'Content-Type: application/json' 

.PHONY: deploy-knowledge-base
deploy-knowledge-base:
	aws cloudformation deploy --template-file $(WORK_DIR)/03-knowledge-base.yaml --stack-name $(AWS_STACK_NAME)-knowledge-base --capabilities CAPABILITY_NAMED_IAM --region $(AWS_REGION) --profile $(AWS_PROFILE)

.PHONY: destroy-all
destroy-all:
	aws cloudformation deploy delete-stack --stack-name $(AWS_STACK_NAME)-open-search --region $(AWS_REGION) --profile $(AWS_PROFILE)
	aws cloudformation deploy delete-stack --stack-name $(AWS_STACK_NAME)-knowledge-base --region $(AWS_REGION) --profile $(AWS_PROFILE)
