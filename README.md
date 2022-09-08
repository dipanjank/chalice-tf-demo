# chalice-tf-demo

Project Structure
-----------------

This repository contains a simple example of how to combine Chalice and Terraform Deployments.

* [main.tf](./setup-infra/main.tf) creates

  - An AWS VPC
  - Public and private subnets 
  - An IAM role used to deploy the Lambda functions
  - Security Group for the the Lambda functions
  - Two S3 buckets, ``chalice-demo-input-bucket`` and ``chalice-demo-output-bucket``
  - An SQS Queue, named ``sum-rows-queue``

* [sum-rows](./sum-rows) is a [Chalice](https://github.com/aws/chalice) App. It contains two Lambda functions.

* ``sum_rows_input`` is configured an S3 Trigger. When a CSV file is uploaded to ``incoming`` prefix in the 
``chalice-demo-input-bucket``, this function loads the file into a pandas DataFrame, sums each row, and
and posts the result as a message to the SQS queue.

* ``handle_row_sum`` is configured with an SQS trigger. It receives the above message, prints it, and the moves the
CSV file from ``chalice-demo-input-bucket`` to ``chalice-demo-output-bucket``.

Deployment
----------

The [deployment workflow](.github/workflows/ci.yaml) contains two Jobs. 

* ``run_terraform`` runs and applies the terraform code for the main branch.
* ``deploy-chalice-app`` deploys the chalice app for the main branch.

References
----------

* [Main Chalice Docs](https://aws.github.io/chalice/topics/index.html)
