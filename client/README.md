# Chatbot Client

The chatbot client is an example python application that makes use of the [`streamlit`](https://streamlit.io/) library to build a simple user interface. 

The chatbot client communicates with [Amazon Bedrock](https://aws.amazon.com/bedrock/) via an [AWS Lambda](https://aws.amazon.com/lambda/) function.

## Getting Started

Before modifying or running the chatbot client, you will need to install a number of prerequisites.

### Prerequisites

This project requires the following tools:

- [Python 3](https://www.python.org/)
- [Make](https://www.gnu.org/software/make/)

### Available Scripts

From the client directory, you can run:

- `make help` - displays the help message
- `make clean` - cleans the project directory and removes `venv` directory
- `make setup` - performs the initial setup of the project directory
- `make install` - installs the dependencies for this project
- `make run` - runs the application in dev mode

### Usage

The chatbot client is designed to be run directly via python, alternatively the `make run` target can be used.

Before running the client you will need to setup the project, and install all project dependencies, using the following commands:

```shell
$ make setup
$ make install
```

_Note: setting up and installing project dependencies is a one time operation._

To run the application, use the following command:

```shell
$ make run
```

Once the application is running, your browser should display the application.
