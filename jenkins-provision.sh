# This is the shell script which will be called by Jenkins master to do Terraform plan execution as well as Terraform Apply. 

# Below command will delete any existing tf.statefiles if they exist

rm -rf  terraform.tfstate

# Below Terraform Plan command is going to verify the key-value pairs that were passed on through Main.tf & Variables.tf files,if there are any errors it will fail the plan execution.

terraform plan

# Below is the command to execute  Terraform Apply, this step will establish connection with AWS using access keys through cloud API calls and provision the infrastructure defined in the Terraform scripts.

terraform apply

# Now Terraform execution will generate s statefile which needs to be moved to a repository for further management of infrastructure resources, below command will move the state file to AWS S3 Bucket.

aws s3 mv /usr/local/src/infra/terraform.tfstate s3://iac-statefile-repo