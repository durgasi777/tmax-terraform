resource "aws_iam_role" "this" {
  name               = "${var.env}-app"
  description        = "IAM Role"
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

resource "aws_iam_policy" "this" {
  name        = "${var.env}-app"
  path        = "/${var.env}/"
  description = "IAM Policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject"
          ],
          "Resource": ["arn:aws:s3:::*"]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambdaInstanceRole" {
   for_each   = toset([
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  ])
  role       = aws_iam_role.this.name
  policy_arn = each.value 
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.env}-app"
  role = aws_iam_role.this.name
  path = "/${var.env}/"
}
