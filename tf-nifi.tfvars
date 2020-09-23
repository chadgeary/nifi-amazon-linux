# aws profile (e.g. from aws configure, usually "default")
aws_profile = "default"
aws_region = "us-east-1"

# existing aws iam user granted access to the kms key (for browsing KMS encrypted services like S3 or SNS).
kms_manager = "some_iam_user"

# the subnet permitted to browse nifi (port 443) via the AWS ELB
mgmt_cidr = "127.0.0.0/30"

# a unique bucket name to store various input/output
bucket_name = "some-bucket-abc123"

# public ssh key
instance_key = "ssh-rsa AAAAB3NzaD2yc2EAAAADAQABAAABAQCNsxnMWfrG3SoLr4uJMavf43YkM5wCbdO7X5uBvRU8oh1W+A/Nd/jie2tc3UpwDZwS3w6MAfnu8B1gE9lzcgTu1FFf0us5zIWYR/mSoOFKlTiaI7Uaqkc+YzmVw/fy1iFxDDeaZfoc0vuQvPr+LsxUL5UY4ko4tynCSp7zgVpot/OppqdHl5J+DYhNubm8ess6cugTustUZoDmJdo2ANQENeBUNkBPXUnMO1iulfNb6GnwWJ0Z5TRRLGSu2gya2wMLeo1rBJ5cbZZgVLMVHiKgwBy/svUQreR8R+fpVW+Q4rx6sPAltLaOUONn0SF2BvvJUueqxpAIaA2rU4MS420P"

# size according to workloads, t3a.small is -just- enough
instance_type = "r5a.large"

# the root block size of the instances (in GiB)
instance_vol_size = 15

# the name prefix for the AMI and instances (e.g. "tf-nifi" for "tf-nifi-encrypted-ami", "tf-nifi-zookeeper-1", ...)
ec2_name_prefix = "tf-nifi"

# the vendor supplying the AMI and the AMI name - default is official Ubuntu 1804 
vendor_ami_account_number = "amazon"
vendor_ami_name_string = "amzn2-ami-hvm-2.0.20200207.1-x86_64-ebs"

# the mirror nifi / zookeeper / toolkit are downloaded from - and the versions
mirror_host = "mirror.cogentco.com"
nifi_version = "1.12.0"
zk_version = "3.6.1"

# vpc specific vars, modify these values if there would be overlap with existing resources.
vpc_cidr = "10.10.10.0/24"
pubnet1_cidr = "10.10.10.0/28"
pubnet2_cidr = "10.10.10.16/28"
pubnet3_cidr = "10.10.10.32/28"
prinet1_cidr = "10.10.10.64/26"
prinet2_cidr = "10.10.10.128/26"
prinet3_cidr = "10.10.10.192/26"
node1_ip = "10.10.10.71"
node2_ip = "10.10.10.133"
node3_ip = "10.10.10.197"
encrypted_ami_ip = "10.10.10.72"

# the initial size (min) and max count of non-zookeeper Autoscaling Group NiFi nodes, scale is based on CPU load (see tf-nifi-scaling.tf)
minimum_node_count = 0
maximum_node_count = 3
