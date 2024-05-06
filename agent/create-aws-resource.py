import os
import time
import boto3

# AWS Region that the lambda function is executing in
DEFAULT_AWS_REGION = os.getenv('AWS_REGION', 'us-east-1')

# A utility function to obtain the params as a dictionary
def get_parameters(params_list):
    params_dict = {}
    for param in params_list:
        name = param['name']
        value = param['value']

        if param['type'] == 'integer':
            value = int(value)
        elif param['type'] == 'boolean':
            value = bool(value)
        
        params_dict[name] = value

    return params_dict

# Main Lambda function handler
def lambda_handler(event, context):
    agent = event['agent']
    actionGroup = event['actionGroup']
    function = event['function']
    parameters = event.get('parameters', [])  

    # Create the AWS resource
    requestParams = get_parameters(parameters)
    resource = requestParams.get('resource', 'N/A')
    region = requestParams.get('region', DEFAULT_AWS_REGION)
    name = requestParams.get('name', f'bedrock-agent-{int(round(time.time() * 1000))}').replace(' ', '-').lower()

    if 'sqs' in resource.casefold():
        client = boto3.client('sqs', region_name=region)
        client.create_queue(QueueName=name, tags={ 'CreatedBy': 'Bedrock Agent invoking Lambda' })

    elif 'sns' in resource.casefold():
        client = boto3.client('sns', region_name=region)
        client.create_queue(Name=name, tags={ 'CreatedBy': 'Bedrock Agent invoking Lambda' })

    # Return a response
    action_response = {
        'actionGroup': actionGroup,
        'function': function,
        'functionResponse': {
            'responseBody': {
                "TEXT": {
                    "body": "The function {} was called successfully!".format(function)
                }
            }
        }
    }

    return {
        'response': action_response, 
        'messageVersion': event['messageVersion']
    }
