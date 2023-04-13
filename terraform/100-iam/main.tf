#################################################################
#           Create Croos account role for Databricks            #
#################################################################

resource "aws_iam_role" "cross_role" {
  name               = "cross_role_databricks"
  assume_role_policy = data.aws_iam_policy_document.assume_role_permission.json
  inline_policy {
    name   = "inline-police_databricks"
    policy = data.aws_iam_policy_document.inline_policy_permission.json
  }
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/platform/ALZP-WL-PermissionsBoundary"
}

#################################################################
#                    Call the current user                      #
#################################################################

data "aws_caller_identity" "current" {}


#################################################################
#              Retrieve VPC ID created by AWS LZ                #
#################################################################

data "aws_vpc" "odb_vpc" {
  id = var.vpc_id
}

#################################################################
#           Create policy document for assume role              #
#################################################################

data "aws_iam_policy_document" "assume_role_permission" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.databricks_account_id]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["${var.external_id}"]
    }
  }

}

#################################################################
#           Create policy document for inline policy            #
#################################################################

data "aws_iam_policy_document" "inline_policy_permission" {
  version = "2012-10-17"
  statement {
    sid     = "NonResourceBasedPermissions"
    effect  = "Allow"
    actions = [
      "ec2:CancelSpotInstanceRequests",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeIamInstanceProfileAssociations",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInstances",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNatGateways",
      "ec2:DescribeNetworkAcls",
      "ec2:DescribePrefixLists",
      "ec2:DescribeReservedInstancesOfferings",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotInstanceRequests",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets",
      "ec2:DescribeVolumes",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeVpcs",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:RequestSpotInstances"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid     = "InstancePoolsSupport"
    effect  = "Allow"
    actions = [
      "ec2:AssociateIamInstanceProfile",
      "ec2:DisassociateIamInstanceProfile",
      "ec2:ReplaceIamInstanceProfileAssociation"
    ]
    resources = ["arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*"]
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Vendor"
      values   = ["Databricks"]
    }

  }


  statement {
    sid       = "AllowEc2RunInstancePerTag"
    effect    = "Allow"
    actions   = ["ec2:RunInstances"]
    resources = [
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:volume/*",
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Vendor"
      values   = ["Databricks"]
    }
  }

  statement {
    sid       = "AllowEc2RunInstanceImagePerTag"
    effect    = "Allow"
    actions   = ["ec2:RunInstances"]
    resources = [
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:image/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Vendor"
      values   = ["Databricks"]
    }
  }

  statement {
    sid       = "AllowEc2RunInstancePerVPCid"
    effect    = "Allow"
    actions   = ["ec2:RunInstances"]
    resources = [
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:network-interface/*",
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:subnet/*",
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:security-group/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:vpc"
      values   = [
        "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:vpc/${data.aws_vpc.odb_vpc.id}"
      ]
    }

  }


  statement {
    sid           = "AllowEc2RunInstanceOtherResources"
    effect        = "Allow"
    actions       = ["ec2:RunInstances"]
    not_resources = [
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:image/*",
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:network-interface/*",
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:subnet/*",
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:security-group/*",
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:volume/*",
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*"
    ]
  }

  statement {
    sid     = "EC2TerminateInstancesTag"
    effect  = "Allow"
    actions = [
      "ec2:TerminateInstances"
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Vendor"
      values   = ["Databricks"]
    }
  }

  statement {
    sid     = "EC2AttachDetachVolumeTag"
    effect  = "Allow"
    actions = [
      "ec2:AttachVolume",
      "ec2:DetachVolume"
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*",
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:volume/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Vendor"
      values   = ["Databricks"]
    }
  }

  statement {
    sid     = "EC2CreateVolumeByTag"
    effect  = "Allow"
    actions = [
      "ec2:CreateVolume"
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:volume/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Vendor"
      values   = ["Databricks"]
    }

  }
  statement {
    sid     = "EC2DeleteVolumeByTag"
    effect  = "Allow"
    actions = [
      "ec2:DeleteVolume"
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:volume/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Vendor"
      values   = ["Databricks"]
    }
  }
  statement {
    effect  = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole",
      "iam:PutRolePolicy"
    ]
    resources = ["arn:aws:iam::*:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot"]
    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values   = ["spot.amazonaws.com"]
    }

  }

  statement {
    sid     = "VpcNonresourceSpecificActions"
    effect  = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress"
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:security-group/${var.security_group_id}"
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:vpc"
      values   = [
        "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:vpc/${data.aws_vpc.odb_vpc.id}"
      ]
    }
  }

}


