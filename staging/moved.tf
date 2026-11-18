moved {
  from = module.codebuild.aws_security_group.codebuild
  to   = module.codebuild.aws_security_group.this
}

moved {
  from = module.codebuild.aws_iam_role.codebuild
  to   = module.codebuild.aws_iam_role.this
}

moved {
  from = module.codebuild.aws_iam_policy.codebuild_iam
  to   = module.codebuild.aws_iam_policy.iam
}

moved {
  from = module.codebuild.aws_iam_role_policy_attachment.codebuild_poweruser
  to   = module.codebuild.aws_iam_role_policy_attachment.poweruser
}

moved {
  from = module.codebuild.aws_iam_role_policy_attachment.codebuild_iam
  to   = module.codebuild.aws_iam_role_policy_attachment.iam
}

moved {
  from = module.codebuild.aws_codebuild_project.plan
  to   = module.codebuild.aws_codebuild_project.this["plan"]
}

moved {
  from = module.codebuild.aws_codebuild_project.apply
  to   = module.codebuild.aws_codebuild_project.this["apply"]
}
