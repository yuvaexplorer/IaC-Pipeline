# README #



**What is this repository for?**
Automating Infrastructure/Application Deployments through IaC using pipeline approach


**Quick summary**
Automating Infrastructure as well as Application Deployments on any cloud provider through pipeline approach by integrating tools i.e. BitBucket, Jenkins (Slave machines), Terraform, Chef & AWS S3 (To manage Terraform-state files).


**Version**
1.0.0


**Requirements:**

 *Source code repository*

	Atlassian BitBucket

 *Integration tool*

	Jenkins & slave nodes v. 2.60.3

 *Infrastructure provisioning tool*

	Terraform- v.0.9

 *Configuration management tool*

	Chef 12.1+

 *Cookbooks*

	Apache 2.0 HTTPD Cookbook v.0.4.5
	Java Cookbook v.1.8.0

 *State files management*

	AWS S3 Bucket

 *Platforms*

	RHEL-7
	Amazon Linux

 *Cloud Services Provider*

	AWS


## Pipeline Configuration & Usage Details ##


# Atlassian BitBucket:

Pre-developed Terraform files, shell scripts and dependent data which is required for infrastructure/applications deployment is committed to BitBucket repository. 

	Jenkins-Destroy.sh
	Jenkins-Provision.sh
	Main.tf
	Variables.tf
	Userdata.txt
	README.md

BitBucket repository is integrated with Jenkins master hence triggering a Jenkins job will pull code & files from BitBucket repository.

Note: 
We are not exposing AWS access keys and secret access keys in variables.tf for security reasons; we are specifying keys in workspace folder of Jenkins Master,  which will be called while files are moved to Jenkins master from BitBucket repository.


# Jenkins & Slave Nodes Setup

** Jenkins Master **

Create 2 instances- Master node (RHEL/Amazon Linux) and Slave node (Amazon Linux)

Install Jenkins on Master node. Installing Jenkins need Java 1.7.0 or greater than Java 1.7.0. To install Jenkins, follow instructions to add a Yum repo 
which contains Jenkins binaries and then install it using yum


Add the Jenkins repo using the following command:

	Sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo 

Import a key file from Jenkins-CI to enable installation from the package:

	sudo rpm –import  https://pkg.jenkins.io/redhat/jenkins.io.key 

Install Jenkins: 

	sudo yum install jenkins -y
	sudo service jenkins start
	sudo service jenkins status

To open Jenkins & to configure Jenkins:

	http://DNS-Name:8080
	To procure initial password to logon to Jenkins console, see: /var/lib/jenkins/secrets/initialAdminPassword

Installation of Maven:

	wget http://mirror.olnevhost.net/pub/apache/maven/binaries/apache-maven-3.2.1-bin.tar.gz 
	sudo tar xzvf apache-maven-3.2.1-bin.tar.gz 
	rm -rf apache-maven-3.2.1-bin.tar.gz

** Jenkins Slave Configuration **

  1. Copy Master's public key to Slave nodes (To enable talks between our master and slave nodes, we need to public key [id_rsa.pub] of the master into slave's authorized_keys.)
  2. Install JRE & GIT on slave nodes
  3. Check Installation of AWS CLI, if slave node is Amazon Linux by default AWS CLI is pre-installed (To copy & fetch Terraform state files from S3 Buckets through AWS-CLI operations)
  4. Logon to Jenkins console, on Master Jenkins, click "Build Executor Status", and select "New Node". Type in "Node name", and select "Permanent Agent".
  5. For Credentials, paste the master's private key i.e. retrieved from (~/.ssh/id_rsa)
  6. Click the "Save" button

** Create Job Configuration details **

Create a new free style project in Jenkins master
In the General section specify below details

1.	Project name

2.	Description

3.	Specify string parameters:

	     S3_REPO_URL and Bucket URL to store Terraform statefiles
	     TFSTATE and default value as tfstatefiles/new/tfstate
	     TF_FILE & file name as "main"
	     USER (BitBucket) and user name as "BitBucket User_name" 
	     PASSWORD and "BitBucket_Password"


4.	In Source Code Management section, select GIT, in Repository URL section specify BitBucket URL and choose credentials, also mention branch details

5.	We are manually building the job so no need to mention Build triggers

6.	In Build- Execute shell command prompt section, paste below script:

     Download and unpack Terraform if not already installed on Jenkins slave machine 

          cd /usr/local/src
          sudo wget https://s3-us-west-2.amazonaws.com/iac-pipeline/packages/terraform_0.8.5_linux_386.zip
          sudo unzip terraform_0.8.5_linux_386.zip
          sudo mv terraform /usr/local/bin/
          export PATH=$PATH:/terraform-path/
          cd /usr/local/src
          sudo rm -rf terraform_0.8.5_linux_386.zip

     Create a local Terraform directory to copy the Terraform files, Shell scripts & other required data 

          sudo mkdir -p infra

     Copy Terraform configuration files & dependent data to infra directory 

          sudo cp /home/ec2-user/workspace/IaC_Create_Job_Demo_Slave-2_RHEL/${TF_FILE}.tf /usr/local/src/infra
          sudo cp /home/ec2-user/workspace/IaC_Create_Job_Demo_Slave-2_RHEL/jenkins-provision.sh /usr/local/src/infra
          sudo cp /home/ec2-user/workspace/IaC_Create_Job_Demo_Slave-2_RHEL/jenkins-Destroy.sh /usr/local/src/infra
          sudo cp /home/ec2-user/workspace/IaC_Create_Job_Demo_Slave-2_RHEL/userdata.txt /usr/local/src/infra
          sudo cp /home/ec2-user/workspace/IaC_Create_Job_Demo_Slave-2_RHEL/variables.tf /usr/local/src/infra
          sudo cp /home/ec2-user/variable.tf /usr/local/src/infra

     Jenkins Provision job to provision infrastructure on AWS

          sudo su -
          cd /usr/local/src/infra
          sudo chmod +x jenkins-provision.sh
          ./jenkins-provision.sh


7.	 Now save the Job


** Jenkins-Provision.sh Execution process **

    This is the shell script which will be called by Jenkins master to do Terraform plan execution as well as Terraform Apply.
    Below command will delete any existing tf.statefiles if they exist 

        rm -rf  terraform.tfstate

    Below Terraform Plan command is going to verify the key-value pairs that were passed on through Main.tf & Variables.tf files,
    if there are any errors it will fail the plan execution.

        terraform plan

    Below is the command to execute  Terraform Apply, this step will establish connection with AWS using access keys
    through cloud API calls and provision the infrastructure defined in the Terraform scripts.

        terraform apply

    Now Terraform execution will generate s statefile which needs to be moved to a repository for further management of 
    infrastructure resources, below command will move the state file to AWS S3 Bucket.

        aws s3 mv /usr/local/src/infra/terraform.tfstate s3://iac-statefile-repo



** Jenkins-Destroy.sh Execution process **

    This is the shell script which will be called by Jenkins master to do Terraform Destroy i.e. to De-provision the infrastructure 
    Below is the command which fetched the statefile stored on S3 bucket to the local directory 

        wget https://s3-us-west-2.amazonaws.com/iac-statefile-repo/terraform.tfstate 

    We are providing read/write/execute permissions for statefile which was downloaded from S3 Bucket.

        chmod 777 terraform.tfstate

    Below Terraform destroy command will establish connection with AWS using access keys (variable.tf) & data in the latest terraform state file 
    that was downloaded from S3 Bucket and through cloud API calls it will execute the de-provisioning of infrastructure resources which were
    previously managed through Terraform.

        terraform destroy -force 

    Below command will Remove State files backup files from current directory, incase if we need statefiles, we can move it to 
    S3 Bucket or any other repositories for future references

        rm -rf terraform.tfstate terraform.tfstate.1 terraform.tfstate.backup 

                          
## Chef ##

** Creating an AMI with pre-installed Chef-Client **

We are launching instances through Terraform and have them automatically connect to a Chef server through pre-installed Chef-Client (AMI with Chef-Client) and pull down a default set of CookBooks and policies.

We have Loaded Chef and the configurations into a custom Amazon Machine Image instead of launching instances using the Knife command-line tool or bootstraping nodes (EC2 instances) from Chef-Workstation.


1. Bootstrap an ec2 instance with knife.
  
         sudo knife bootstrap "IP.Address of the Node" -N Linux_Node --ssh-user ec2-user --sudo --identity-file /home/ec2-user/chef-repo/.chef/your.pem-key



2. Clean the ec2 instance

         Delete /etc/chef/client.pem (This is created once an instance is bootstrapped with Chef-Server, 
         so after first bootstrap any instance is going to communicate with chef-server through client.pem key)

         Delete node_name from /etc/chef/client.rb



3. Chef Node files & scripts

          In /etc/chef/ make sure you have all these files and scripts before taking AMI out of EC2-instance.

                client.rb  
                first-boot.json  
                trusted_certs  
                validation.pem  (Brought from CHef Server)



4. Client.rb file should look like this:

                chef_server_url  "https://ip-xxx-xx-xx-xx.us-west-2.compute.internal/organizations/xxxxcorpxx"
                validation_client_name "chef-validator"
                validation_client_name "y***acorp-validator"
                validation_key "/etc/chef/validation.pem"
                log_location   STDOUT
                node_name "        "
                trusted_certs_dir "/etc/chef/trusted_certs"




5. In the following directory /home/ec2-user/script_run.sh

               script_run.sh: (This script should have write/execute permissions)

      This script will fetch instance_ID and pass node name details to node_name scrion in  client.rb file which is required to bootstrap with chef-server

              _node_name="NodeName-`curl -s http://169.254.169.254/latest/meta-data/instance-id`"
              echo "node_name '$_node_name'" >> /etc/chef/client.rb


6. Generate AMI.



7. I used cloud-init to customize new instances in boot time. The next script is the basic bootstrap.txt that add node name to chef-client configuration and run the chef-client.

          !/bin/bash
          cd /home/ec2-user
          ./script_run.sh
          chef-client
          chef-client -o role[sample-role-rhel]
          service httpd start
          chkconfig httpd on
          echo " <html>
          <body>
          <h1> Hello CFS</h1>
          <h3> Welcome to the Demo</h2>
          <p>
          This is to demonstrate succesfull implementation of Infrastructure/Application deployment through IaC using Pipeline approach !!!
          </p>
          </body>
          </html>" > /var/www/html/index.html
          service httpd restart

 Detailed description of the script


   Executing script_run.sh will pass node name to client.rb file

              ./script_run.sh

   Executing the first Chef-Client run

              chef-client   

   Here, we are passing the chef roles to install Apachae 2.0 & Java 1.8.0 coookbooks on the instance

              chef-client -o role[sample-role-rhel]

   Once the chef roles installs required software i.e. Apache 2.0 (Httpd), service needs to be started.

              service httpd start
              chkconfig httpd on

   Below is the Html script which is going to be passed on to /var/www/html/index.html & http service will be re-started

              echo " <html>
              <body>
              <h1> Hello CFS</h1>
              <h3> Welcome to the Demo</h2>
              <p> This is to demonstrate succesfull implementation of Infrastructure/Application 
              deployment through IaC using Pipeline approach !!!
              </p>
              </body>
              </html>" > /var/www/html/index.html
              service httpd restart



## Known Issues ##



## Who do I talk to, to get more details? ##

* Yuva Kishore
* yuvaexplorer28@gmail.com
* Other community or team contact - "Will update soon"

