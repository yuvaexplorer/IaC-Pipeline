## This is the shell script which will be called by Jenkins master to do Terraform Destroy i.e. to De-provision the infrastructure 

# Below is the command which fetched the statefile stored on S3 bucket to the local directory

wget https://s3-us-west-2.amazonaws.com/iac-statefile-repo/terraform.tfstate 

# We are providing read/write/execute permissions for statefile which was downloaded from S3 Bucket.

chmod 777 terraform.tfstate

# Below Terraform destroy command will establish connection with AWS using access keys (variable.tf) & data in the latest terraform state file that was downloaded from S3 Bucket and through cloud API calls it will execute the de-provisioning of infrastructure resources which werepreviously managed through Terraform.

terraform destroy -force 

# Below command will Remove State files backup files from current directory, incase if we need statefiles, we can move it to S3 Bucket or any other repositories for future references

rm -rf terraform.tfstate terraform.tfstate.1 terraform.tfstate.backup 


