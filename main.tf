/* This is the Terraform Configuration file for for an EC2 instance along with Chef roles
  and Index.html content passedon through user_data parameter. */

/* The provider section needs to be configured with the proper name & region details so that Terraform can 
  interact with cloud services provider through API calls (In the current script AWS is the cloud service provider). */

/* In the provider section we have passedon region details. acces key & secret access keys were defined in the form of variables,
   where actuall access keys are located in Central Jenkins machine for additional security & to avoid exposing keys. */

provider "aws" {

    access_key = "${var.AWS_ACCESS_KEY}"

    secret_key = "${var.AWS_SECRET_KEY}"

    region     = "    "
}

/* Resources are components of your infrastructure which Terraform is going to configure.
 This Terraform script has a single resource i.e. aws_instance with the resource name "test", 
 this resource has all the required parameters i.e. ami/instance_type and optional parameters
 i.e. count, tags, vpc-security group, avilability zone & subnet_ids which needs to be passed 
 through either variables file or through Hardcoding */

resource "aws_instance" "test" {
 
  count                  = 1
  ami                    = "${var.ami_id}"
  availability_zone      = "${var.availability_zone_details}"
  instance_type          = "${var.instance_type_details}"


/* Below is the optional parameter to define security groups */

 vpc_security_group_ids = [  "     " ]
  

/* This is the template provider which exposes Chef-Cookbook Roles during bootstrapping process 
   to manage instances or to install softwares, through template provider we can also pass on cloud-init scripts.
   In the below code snippet we have used "userdata.txt" file to mention chef-cookbook roles to install & configure 
   Java as well as Httpd also to pass html script Httpd service */

  user_data             = "${file("userdata.txt")}"


  subnet_id             = "${var.subnet_id_details}"
  root_block_device {
      
  volume_type            = "gp2"
      
   } 
  

 tags { 
      
  CreatedBy = "${var.owner_details}"
  Server    = "${var.server_details}"

  }


}   


/* Below mentioned resource creates an Encrypted EBS volume "EBS_Vol_1" with required Tags and attach to EC2 insgance i.e. {ec2_instance.test}
For "aws_ebs_volume" resource, size and type of the volume are required parameters, rest are optional */


resource "aws_ebs_volume" "EBS_Vol_1" {
 depends_on         =   ["aws_instance.test"]
 count              =   "1"
 availability_zone  =   "${var.availability_zone_details}"
 encrypted          =   "true"
 kms_key_id         =   "${var.kms_key_details}"
 size               =   "${var.vol_size_details}"
 type               =   "${var.vol_type_details}"

 tags {
        Name        =   "EBS_Vol_1"
        Owner       =   "${var.ebs_vol_owner}"
        managed_by  =   "Terraform"
    }
}

/* Below mentioned resource creates an Encrypted EBS volume "EBS_Vol_2" with required Tags and
 attach to EC2 instance i.e. {ec2_instance.test} */
 
resource "aws_ebs_volume" "EBS_Vol_2" {
  depends_on        =   ["aws_instance.test"]
  count             =   "1"
  availability_zone =   "${var.availability_zone_details}"
  encrypted         =   "true"
  kms_key_id        =   "${var.kms_key_details}"
  size              =   "${var.vol_size_details}"
  type              =   "${var.vol_type_details}"

  tags {
        Name        =   "EBS_Vol_2"
        Owner       =   "${var.ebs_vol_owner}"
        managed_by  =   "Terraform"
    }
}

 
# Below resource will attach/detach "EBS_Vol_1" volume to AWS Instance i.e. {aws_instance.test}
 
resource "aws_volume_attachment" "EBS_Vol_1" {
  count            = "1"
  device_name      = "/dev/xvdf"
  volume_id        = "${aws_ebs_volume.EBS_Vol_1.0.id}"
  instance_id      = "${aws_instance.test.0.id}"
  force_detach     = "true"
}
 
# Below resource will attach/detach "EBS_Vol_2" volume from AWS Instance i.e. {aws_instance.test}
 
resource "aws_volume_attachment" "EBS_Vol_2" {
  count            = "1"
  device_name      = "/dev/xvdg"
  volume_id        = "${aws_ebs_volume.EBS_Vol_2.0.id}"
  instance_id      = "${aws_instance.test.0.id}"
  force_detach     = "true"
}


/* This Terraform script has an "aws_s3_bucket" & "aws_s3_bucket_object" resource with required & optional parameters */
 
resource "aws_s3_bucket" "test_bucket" {
  bucket = "${var.bucket_name}"
  acl    = "private"
 
  versioning {

    enabled = false
  }
 
  tags {

    Name           = "${var.bucket_name_tag}"
    Owner          = "${var.bucket_owner}"

  }
}
 
