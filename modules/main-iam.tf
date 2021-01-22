# Master
data "template_file" "master_policy_json" {
  template = file("./modules/add-ons/add-on-policy/master-policy.json.tpl")
  vars     = {}
}

resource "aws_iam_policy" "master_policy_1" {
  name   = "master_policy_1"
  policy = data.template_file.master_policy_json.rendered
}

resource "aws_iam_role" "master_role_1" {
  name = "master_role_1"

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
  roles      = [aws_iam_role.master_role_1.name]
  policy_arn = aws_iam_policy.master_policy_1.arn
}

resource "aws_iam_instance_profile" "master_profile_1" {
  name = "master_profile_1"
  role = aws_iam_role.master_role_1.name
}


# Node
data "template_file" "node_policy_json" {
  template = file("./modules/add-ons/add-on-policy/node-policy.json.tpl")

  vars = {}
}

resource "aws_iam_policy" "node_policy_1" {
  name   = "node_policy_1"
  policy = data.template_file.node_policy_json.rendered
}

resource "aws_iam_role" "node_role_1" {
  name = "node_role_1"

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
  roles      = [aws_iam_role.node_role_1.name]
  policy_arn = aws_iam_policy.node_policy_1.arn
}

resource "aws_iam_instance_profile" "node_profile_1" {
  name = "node_profile_1"
  role = aws_iam_role.node_role_1.name
}
