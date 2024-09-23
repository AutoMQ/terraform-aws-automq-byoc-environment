# AWS AutoMQ BYOC Environment Terrafrom module
![General_Availability](https://img.shields.io/badge/Lifecycle_Stage-General_Availability(GA)-green?style=flat&logoColor=8A3BE2&labelColor=rgba)

This module is designed for deploying the AutoMQ BYOC (Bring Your Own Cloud) environment using the AWS Provider within an AWS cloud environment.

Upon completion of the installation, the module will output the endpoint of the AutoMQ BYOC environment along with the initial username and password. Users can manage the resources within the environment through the following two methods:

- **Using the Web UI to manage resources**: This method allows users to manage instances, topics, ACLs, and other resources through a web-ui.
- **Using Terraform to manage resources**: This method requires users to access the AutoMQ BYOC environment via a web browser for the first time to create a Service Account. Subsequently, users can manage resources within the environment using the Service Account's Access Key and the AutoMQ Terraform Provider.

For managing instances, topics, and other resources within the AutoMQ BYOC environment using the AutoMQ Terraform Provider, please refer to the [documentation](https://registry.terraform.io/providers/AutoMQ/automq/latest/docs).

# Prerequisites: Subscribe to AutoMQ Service on AWS Marketplace

Before setting up the environment, you need to subscribe to the AutoMQ service on AWS Marketplace. This subscription is necessary for subsequent Terraform calls. You can find the AutoMQ product page by clicking [this link](https://aws.amazon.com/marketplace/pp/prodview-4k5ildfqsqzfo).

Once you access the product page, click "Continue to Subscribe."
![Service Product Screenshot](https://image.automq.com/20240829bot/nhl79d.png)

Agree to the terms and conditions to complete the service subscription.
![Agree to Service Terms](https://image.automq.com/20240829bot/bm5iol.png)


# Module Usage
Use this module to install the AutoMQ BYOC environment, supporting two modes:

- **Create a new VPC**: Recommended only for POC or other testing scenarios. In this mode, the user only needs to specify the region, and resources including VPC, Endpoint, Security Group, S3 Bucket, etc., will be created. After testing, all resources can be destroyed with one click.
- **Using an existing VPC**: Recommended for production environments. In this mode, the user needs to provide a VPC, subnet, and S3 Bucket that meet the requirements. AutoMQ will deploy the BYOC environment console to the user-specified subnet.

## Quick Start

1. **Install Terraform**

   Ensure Terraform is installed on your system. You can download it from the [Terraform website](https://www.terraform.io/downloads.html).

2. **Configure AWS Credentials**

   Make sure your AWS CLI is configured with the necessary credentials. You can configure it using the following command:

   ```bash
   aws configure
   ```

3. **Create Terraform Configuration File**

   Create a file named `main.tf` in your working directory and add the following content:

### Create a new VPC

```terraform
module "automq-byoc" {
  source = "AutoMQ/automq-byoc-environment/aws"

  # Set the identifier for the environment to be installed. This ID will be used for naming internal resources. The environment ID supports only uppercase and lowercase English letters, numbers, and hyphens (-). It must start with a letter and is limited to a length of 32 characters.
  automq_byoc_env_id                       = "example" 

  # Set the target regionId of aws
  cloud_provider_region                    = "ap-southeast-1"  
}

# Necessary outputs
output "automq_byoc_env_id" {
  value = module.automq-byoc.automq_byoc_env_id
}

output "automq_byoc_endpoint" {
  value = module.automq-byoc.automq_byoc_endpoint
}

output "automq_byoc_initial_username" {
  value = module.automq-byoc.automq_byoc_initial_username"
}

output "automq_byoc_initial_password" {
  value = module.automq-byoc.automq_byoc_initial_password
}

output "automq_byoc_vpc_id" {
  value = module.automq-byoc.automq_byoc_vpc_id
}

output "automq_byoc_instance_id" {
  value = module.automq-byoc.automq_byoc_instance_id
}

```

### Using an existing VPC

To install the AutoMQ BYOC environment using an existing VPC, ensure your existing VPC meets the necessary requirements. You can find the detailed requirements in the [Prepare VPC Documents](https://docs.automq.com/automq-cloud/getting-started/install-byoc-environment/aws/prepare-vpc).

```terraform
module "automq-byoc" {
  source = "AutoMQ/automq-byoc-environment/aws"
  
  # Set the identifier for the environment to be installed. This ID will be used for naming internal resources. The environment ID supports only uppercase and lowercase English letters, numbers, and hyphens (-). It must start with a letter and is limited to a length of 32 characters.  
  automq_byoc_env_id                       = "example"

  # Set the target regionId of aws    
  cloud_provider_region                    = "ap-southeast-1" 

  # Set this switch to false, use existed vpc  
  create_new_vpc                           = false   

  # Set this existed vpc
  automq_byoc_vpc_id                       = "vpc-022xxxx54103b"  

  # Set the subnet for deploying the AutoMQ environment console. This subnet must support internet access, and EC2 instances created within this subnet must be able to access the internet.
  automq_byoc_env_console_public_subnet_id = "subnet-09500xxxxxb6fd28"  
  
}

# Necessary outputs
output "automq_byoc_env_id" {
  value = module.automq-byoc.automq_byoc_env_id
}

output "automq_byoc_endpoint" {
  value = module.automq-byoc.automq_byoc_endpoint
}

output "automq_byoc_initial_username" {
  value = module.automq-byoc.automq_byoc_initial_username
}

output "automq_byoc_initial_password" {
  value = module.automq-byoc.automq_byoc_initial_password
}

output "automq_byoc_vpc_id" {
  value = module.automq-byoc.automq_byoc_vpc_id
}

output "automq_byoc_instance_id" {
  value = module.automq-byoc.automq_byoc_instance_id
}

```

4. **Initialize Terraform**

   Run the following command to initialize Terraform:

   ```bash
   terraform init
   ```

5. **Apply Terraform Configuration**

   Run the following command to apply the Terraform configuration and create the resources:

   ```bash
   terraform apply
   ```

   Confirm the action by typing `yes` when prompted.

6. **Retrieve Outputs**

   After the deployment is complete, run the following command to retrieve the outputs:

   ```bash
   terraform output
   ```

   This will display the AutoMQ environment console endpoint, initial username, and initial password.

7. **Access AutoMQ Environment Console**

   Use the `automq_byoc_endpoint`, `automq_byoc_initial_username`, and `automq_byoc_initial_password` to access the AutoMQ environment console via a web browser.

8. **Manage Resources**

   You can manage resources within the AutoMQ BYOC environment using the Web UI or Terraform. For more details, refer to the [documentation](https://docs.automq.com/automq-cloud/manage-identities-and-access/member-accounts).

9. **Clean Up Resources**

   If you no longer need the resources, you can destroy them by running:

   ```bash
   terraform destroy
   ```

   Confirm the action by typing `yes` when prompted.

# Helpful Links/Information

* [Report Bugs](https://github.com/AutoMQ/terraform-aws-automq-byoc-environment/issues)

* [AutoMQ Cloud Documents](https://docs.automq.com/automq-cloud/overview)

* [Request Features](https://automq66.feishu.cn/share/base/form/shrcn7qXbb5aKiYbKqbJtPlGWXc)


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | >= 5.30 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 5.30 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_automq_byoc_data_bucket_name"></a> [automq_byoc_data_bucket_name](#module_automq_byoc_data_bucket_name) | terraform-aws-modules/s3-bucket/aws | 4.1.2 |
| <a name="module_automq_byoc_ops_bucket_name"></a> [automq_byoc_ops_bucket_name](#module_automq_byoc_ops_bucket_name) | terraform-aws-modules/s3-bucket/aws | 4.1.2 |
| <a name="module_automq_byoc_vpc"></a> [automq_byoc_vpc](#module_automq_byoc_vpc) | terraform-aws-modules/vpc/aws | 5.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ebs_volume.data_volume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_iam_instance_profile.automq_byoc_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.automq_byoc_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.automq_byoc_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.automq_byoc_role_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.automq_byoc_console](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_route53_zone.private_r53](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_security_group.automq_byoc_console_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vpc_endpoint_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_volume_attachment.data_volume_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_vpc_endpoint.ec2_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.s3_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_ami.marketplace_ami_details](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available_azs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_ssm_parameter.marketplace_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.public_subnet_info](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.vpc_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_automq_byoc_env_id"></a> [automq_byoc_env_id](#input_automq_byoc_env_id) | The unique identifier of the AutoMQ environment. This parameter is used to create resources within the environment. Additionally, all cloud resource names will incorporate this parameter as part of their names. This parameter supports only numbers, uppercase and lowercase English letters, and hyphens. It must start with a letter and is limited to a length of 32 characters. | `string` | n/a | yes |
| <a name="input_cloud_provider_region"></a> [cloud_provider_region](#input_cloud_provider_region) | Set the cloud provider's region. AutoMQ will deploy to this region. | `string` | n/a | yes |
| <a name="input_create_new_vpc"></a> [create_new_vpc](#input_create_new_vpc) | This setting determines whether to create a new VPC. If set to true, a new VPC spanning three availability zones will be automatically created, which is recommended only for POC scenarios. For production scenario using AutoMQ, you should provide the VPC where the current Kafka application resides and check the current VPC against the requirements specified in the [Prepare VPC Documents](https://docs.automq.com/automq-cloud/getting-started/install-byoc-environment/aws/prepare-vpc). | `bool` | `true` | no |
| <a name="input_automq_byoc_vpc_id"></a> [automq_byoc_vpc_id](#input_automq_byoc_vpc_id) | When the `create_new_vpc` parameter is set to `false`, this parameter needs to be set. Specify an existing VPC where AutoMQ will be deployed. When providing an existing VPC, ensure that the VPC meets [AutoMQ's requirements](https://docs.automq.com/automq-cloud/getting-started/install-byoc-environment/aws/prepare-vpc). | `string` | `""` | no |
| <a name="input_automq_byoc_env_console_public_subnet_id"></a> [automq_byoc_env_console_public_subnet_id](#input_automq_byoc_env_console_public_subnet_id) | When the `create_new_vpc` parameter is set to `false`, this parameter needs to be set. Select a subnet for deploying the AutoMQ BYOC environment console. Ensure that the chosen subnet supports public access. | `string` | `""` | no |
| <a name="input_automq_byoc_env_console_cidr"></a> [automq_byoc_env_console_cidr](#input_automq_byoc_env_console_cidr) | Set CIDR block to restrict the source IP address range for accessing the AutoMQ environment console. If not set, the default is 0.0.0.0/0. | `string` | `"0.0.0.0/0"` | no |
| <a name="input_automq_byoc_data_bucket_name"></a> [automq_byoc_data_bucket_name](#input_automq_byoc_data_bucket_name) | Set the existed S3 bucket used to store message data generated by applications. If this parameter is not set, a new S3 bucket will be automatically created. The message data Bucket must be separate from the Ops Bucket. | `string` | `""` | no |
| <a name="input_automq_byoc_ops_bucket_name"></a> [automq_byoc_ops_bucket_name](#input_automq_byoc_ops_bucket_name) | Set the existed S3 bucket used to store AutoMQ system logs and metrics data for system monitoring and alerts. If this parameter is not set, a new S3 bucket will be automatically created. This Bucket does not contain any application business data. The Ops Bucket must be separate from the message data Bucket. | `string` | `""` | no |
| <a name="input_automq_byoc_ec2_instance_type"></a> [automq_byoc_ec2_instance_type](#input_automq_byoc_ec2_instance_type) | Set the EC2 instance type; this parameter is used only for deploying the AutoMQ environment console. You need to provide an EC2 instance type with at least 2 cores and 8 GB of memory. | `string` | `"t3.large"` | no |
| <a name="input_automq_byoc_env_version"></a> [automq_byoc_env_version](#input_automq_byoc_env_version) | Set the version for the AutoMQ BYOC environment console. It is recommended to keep the default value, which is the latest version. Historical release note reference [document](https://docs.automq.com/automq-cloud/release-notes). | `string` | `"latest"` | no |
| <a name="input_specified_ami_by_marketplace"></a> [specified_ami_by_marketplace](#input_specified_ami_by_marketplace) | The parameter defaults to true, which means the AMI will be obtained from AWS Marketplace. If you wish to use a custom AMI, set this parameter to false and specify the `automq_byoc_env_console_ami` parameter with your custom AMI ID. | `bool` | `true` | no |
| <a name="input_automq_byoc_env_console_ami"></a> [automq_byoc_env_console_ami](#input_automq_byoc_env_console_ami) | When parameter `specified_ami_by_marketplace` set to false, this parameter must set a custom AMI to deploy automq console. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_automq_byoc_env_id"></a> [automq_byoc_env_id](#output_automq_byoc_env_id) | This parameter is used to create resources within the environment. Additionally, all cloud resource names will incorporate this parameter as part of their names. This parameter supports only numbers, uppercase and lowercase English letters, and hyphens. It must start with a letter and is limited to a length of 32 characters. |
| <a name="output_automq_byoc_endpoint"></a> [automq_byoc_endpoint](#output_automq_byoc_endpoint) | The endpoint for the AutoMQ environment console. Users can set this endpoint to the AutoMQ Terraform Provider to manage resources through Terraform. Additionally, users can access this endpoint via web browser, log in, and manage resources within the environment using the WebUI. |
| <a name="output_automq_byoc_initial_username"></a> [automq_byoc_initial_username](#output_automq_byoc_initial_username) | The initial username for the AutoMQ environment console. It has the `EnvironmentAdmin` role permissions. This account is used to log in to the environment, create ServiceAccounts, and manage other resources. For detailed information about environment members, please refer to the [documentation](https://docs.automq.com/automq-cloud/manage-identities-and-access/member-accounts). |
| <a name="output_automq_byoc_initial_password"></a> [automq_byoc_initial_password](#output_automq_byoc_initial_password) | The initial password for the AutoMQ environment console. This account is used to log in to the environment, create ServiceAccounts, and manage other resources. For detailed information about environment members, please refer to the [documentation](https://docs.automq.com/automq-cloud/manage-identities-and-access/member-accounts). |
| <a name="output_automq_byoc_vpc_id"></a> [automq_byoc_vpc_id](#output_automq_byoc_vpc_id) | The VPC ID for the AutoMQ environment deployment. |
| <a name="output_automq_byoc_instance_id"></a> [automq_byoc_instance_id](#output_automq_byoc_instance_id) | The EC2 instance id for AutoMQ Console. |
<!-- END_TF_DOCS -->