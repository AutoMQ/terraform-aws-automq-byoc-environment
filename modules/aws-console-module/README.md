# AutoMQ BYOC Console Submodule

## Introduction

This Terraform submodule is used to create and configure EC2 instances, IAM roles and policies, security groups, and Route53 private zones on AWS. The module launches EC2 instances with a specified AMI ID and configures the instances with the corresponding IAM roles and policies for operations on various AWS resources.

## Features

- Create and configure an EC2 instance
- Create and bind IAM roles and policies
- Configure security group rules
- Create a Route53 private zone
- Assign an EIP

## Note

**Note that this submodule only provides resources to the main module, and cannot use the module directly**.