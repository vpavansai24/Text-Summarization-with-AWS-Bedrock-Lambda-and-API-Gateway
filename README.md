# Text Summarization with AWS Bedrock, Lambda, and API Gateway

## Overview

This project provides a solution for text summarization using AWS Bedrock and is deployed via AWS Lambda with API Gateway for RESTful access. The setup includes:

- **AWS Bedrock**: Utilized for text summarization tasks.
- **AWS Lambda**: Handles the text summarization logic and interacts with AWS Bedrock.
- **API Gateway**: Exposes a RESTful API endpoint to trigger the Lambda function.

## Architecture

1. **AWS Lambda**: Executes the text summarization logic using AWS Bedrock.
2. **API Gateway**: Provides a public API endpoint to invoke the Lambda function.
3. **IAM Roles and Policies**: Ensure secure access between Lambda, Bedrock, and CloudWatch.

## Prerequisites

- **AWS Account**: Ensure you have an AWS account with appropriate permissions.
- **AWS CLI**: Install and configure the AWS CLI with necessary credentials.
- **Terraform**: Install Terraform for infrastructure management.

## Setup Instructions

### 1. Configure Your Environment

1. **Install AWS CLI**: Follow the [AWS CLI installation guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).
2. **Install Terraform**: Follow the [Terraform installation guide](https://learn.hashicorp.com/tutorials/terraform/install-cli).

### 2. Configure AWS Access and Secret Access Keys

Before using the AWS CLI or Terraform, configure your AWS credentials. You can set your AWS access key and secret key in your environment variables or AWS credentials file.

**Option 1: Using Environment Variables**

Set the environment variables for AWS credentials:

```bash
export AWS_ACCESS_KEY_ID=your-access-key-id
export AWS_SECRET_ACCESS_KEY=your-secret-access-key
```

**Option 2: Using AWS Credentials File**

Create or update the AWS credentials file (~/.aws/credentials) with the following content:
```
[default]
aws_access_key_id = your-access-key-id
aws_secret_access_key = your-secret-access-key
```
Replace `your-access-key-id` and `your-secret-access-key` with your actual AWS credentials.

### 3. Clone the Repository

```bash
git https://github.com/vpavansai24/Text-Summarization-with-AWS-Bedrock-Lambda-and-API-Gateway.git
cd Text-Summarization-with-AWS-Bedrock-Lambda-and-API-Gateway
```

### 4. Provide Access to Required Bedrock Foundation Models
Ensure that your AWS account has the necessary permissions to access the AWS Bedrock foundation models. You may need to request access to specific Bedrock models from the AWS Management Console.

### 5. Configure Terraform Variables

Before deploying your infrastructure, you may need to customize certain Terraform variables to fit your environment. Follow these steps:

1. **Open the `variables.tf` File**:
   - Locate the `variables.tf` file in the project directory. This file defines the variables used in your Terraform configuration.

2. **Update Variable Values**:
   - Review the variable definitions and update their values as necessary. For example, you might need to specify your desired AWS region, Lambda function name, or other parameters.
   - Example:
     ```hcl
     variable "myregion" {
       description = "The AWS region to deploy resources in."
       default     = "us-east-1"
     }

     variable "lambda_function_name" {
       description = "The name of the Lambda function."
       default     = "MyLambdaFunction"
     }
     ```

3. **Save Your Changes**:
   - After making the necessary updates, save the `variables.tf` file.

Ensure that all required variables are correctly set according to your deployment needs.


### 6. Initialize Terraform
Run the following command to initialize the Terraform workspace:
```bash
terraform init
```

### 7. Plan Terraform Deployment
Generate an execution plan to review the changes Terraform will make:
```bash
terraform plan
```

### 8. Apply Terraform Configuration
Apply the Terraform configuration to create the resources:
```bash
terraform apply
```

### 9. Accessing the API Endpoint

Once the deployment is complete, you can access your API endpoint using the URL provided in the Terraform output. 

To find the endpoint URL:

1. Look for the output in the terminal after running `terraform apply`.
2. The output will include the URL for your API Gateway endpoint.

Here’s an example of how the endpoint URL might look:<br>
https://{api-id}.execute-api.{region}.amazonaws.com/stage/resource


## Testing the Setup

You can test the API endpoint using tools like `curl` or `Postman`.

### Example Request with `curl`

In this example, the text prompt is sent as a query parameter named `prompt`. 

```bash
curl -X POST https://{api-id}.execute-api.{region}.amazonaws.com/stage/resource \
-H "Content-Type: application/json" \
-d '{"prompt": "This is the text that needs summarization."}'
```

### Example Request with Postman

To test the API endpoint using Postman, follow these steps:

1. **Open Postman**.

2. **Set the Request Type to POST**:
   - Click on the dropdown next to the request type (default is GET) and select `POST`.

3. **Enter the URL**:
   - In the request URL field, enter the API Gateway endpoint URL in the following format:
     ```plaintext
     https://{api-id}.execute-api.{region}.amazonaws.com/stage/resource
     ```
   - Replace the URL with the URL from the `terraform apply`.

4. **Configure the Request Body**:
   - Go to the "Body" tab below the URL field.
   - Select "raw" and choose "JSON" from the dropdown menu on the right.
   - Enter the JSON payload:
     ```json
     {
       "prompt": "This is the text that needs summarization."
     }
     ```

5. **Send the Request**:
   - Click the "Send" button.

6. **Check the Response**:
   - Postman will display the response in the lower pane. You should see a response similar to:
     ```json
     "This is the summarized text."
     ```

In this setup, the `prompt` field in the JSON body contains the text you want to summarize. Ensure your request is properly formatted and that the endpoint URL is correct.

