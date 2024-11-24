import {
  to = module.eks.module.eks.aws_iam_openid_connect_provider.oidc_provider[0]
  id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.eu-north-1.amazonaws.com/id/43583B30C4BC756C363DA3A928E9D809"
}

data "aws_caller_identity" "current" {}