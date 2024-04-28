import streamlit as st
import boto3
import json

# AWS Variables
region = boto3.Session().region_name
session = boto3.Session(region_name=region)
lambda_client = session.client('lambda')

# Global Variables
sessionId = ''
role_assistant = 'assistant'
role_user = 'user'

# Application Title
st.title("Amazon Bedrock powered Chatbot")
st.info(f'AWS Region: {region}', icon="ℹ️")


# Initialize chat history
if "messages" not in st.session_state:
    st.session_state.messages = []

# Initialize session id
if 'sessionId' not in st.session_state:
    st.session_state['sessionId'] = sessionId

# Display chat messages from history on app rerun
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# React to user input
if prompt := st.chat_input("What is up?"):
    # Display user input in chat message container
    question = prompt
    st.chat_message(role_user).markdown(question)

    # Call lambda function to get response from the model
    # payload = json.dumps({"question":prompt,"sessionId": st.session_state['sessionId']})
    # print(payload)
    # result = lambda_client.invoke(
    #             FunctionName='InvokeKnowledgeBase',
    #             Payload=payload
    #         )

    # result = json.loads(result['Payload'].read().decode("utf-8"))
    # print(result)

    answer = f'prompt was: "{prompt}" in region {region}'
    # sessionId = result['body']['sessionId']

    # st.session_state['sessionId'] = sessionId

    # Add user input to chat history
    st.session_state.messages.append({"role": role_user, "content": question})

    # Display assistant response in chat message container
    with st.chat_message(role_assistant):
        st.markdown(answer)

    # Add assistant response to chat history
    st.session_state.messages.append({"role": role_assistant, "content": answer})