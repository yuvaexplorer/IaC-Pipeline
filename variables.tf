# This is the variables file where the key value pairs for the Main.tf file were defined here
 
# variable defined for ami
 
variable "ami_id" {
default = "ami-*******"
}
 
# variable defined for choosing instance type
 
variable "instance_type_details" {
default = "t2.micro"
}
 
# variable to define bucket owner tag
 
variable "instance_owner" {
type    = "string"
default = "Yuva_Kishore"
}
 
# variable to define server details
 
variable "server_details" {
type    = "string"
default = "AmazonLinux_Java_Httpd_Test"
}
 
# variable to define EC2_Owner details
 
variable "owner_details" {
type    = "string"
default = "Yuva_Kishore"
}
 

 
# variable to define availability_zone_details
 
variable "availability_zone_details" {
type    = "string"
default = "********"
}
 
# variable to define subnet_id_details
 
variable "subnet_id_details" {
type    = "string"
default = "subnet-*******"
}
 
# variable to define kms_key_details
 
variable "kms_key_details" {
type    = "string"
default = "arn:aws:kms:us-*****-*:*********:key/******-****-****-****-***********"
}
 
# variable to define vol_size_details
 
variable "vol_size_details" {
type    = "string"
default = "10"
}
 
# variable to define vol_type_details
 
variable "vol_type_details" {
type    = "string"
default = "gp2"
}
 
# variable to define ebs_vol_owner
 
variable "ebs_vol_owner" {
type    = "string"
default = "Yuva_kishore"
}
 
# variable defined for the AWS Region
 
variable "aws_region" {
default = "us-****-*"
}
 
# variable to define resource_name for bucket
 
variable "resource_name" {
type = "string"
default = "aws_s3_bucket"
}
 
# variable defined for the bucket name
 
variable "bucket_name" {
type = "string"
default = "Test-Bucket-Name"
}
 
# variable to define bucket name tag
 
variable "bucket_name_tag" {
type = "string"
default = "Test-Bucket-Name"
}
 
# variable to define bucket owner tag
 
variable "bucket_owner" {
type = "string"
default = "Yuva_Kishore"
}
 
