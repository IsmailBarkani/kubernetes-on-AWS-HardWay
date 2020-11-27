# Master

data "template_file" "master_policy_json" {
  template = file("master-policy.json.tpl")
  vars     = {}
}

resource "aws_iam_policy" "master_policy" {
  name = "master_policy"
  #path        = "/"
  policy = data.template_file.master_policy_json.rendered
}

resource "aws_iam_role" "master_role" {
  name = "master_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_policy_attachment" "master-attach" {
  name       = "master-attachment"
  roles      = [aws_iam_role.master_role.name]
  policy_arn = aws_iam_policy.master_policy.arn
}

resource "aws_iam_instance_profile" "master_profile2" {
  name = "master_profile2"
  role = aws_iam_role.master_role.name
}

# Node

data "template_file" "node_policy_json" {
  template = file("node-policy.json.tpl")

  vars = {}
}

resource "aws_iam_policy" "node_policy" {
  name = "node_policy"
  #path = "/"
  policy = data.template_file.node_policy_json.rendered
}

resource "aws_iam_role" "node_role" {
  name = "node_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_policy_attachment" "node-attach" {
  name       = "node-attachment"
  roles      = [aws_iam_role.node_role.name]
  policy_arn = aws_iam_policy.node_policy.arn
}

resource "aws_iam_instance_profile" "node_profile2" {
  name = "node_profile2"
  role = aws_iam_role.node_role.name
}
