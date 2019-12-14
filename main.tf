variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "ap-northeast-1"
}

# VPC作成
resource "aws_vpc" "vpc-1" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_support   = true # AWSのDNSサーバで名前解決有効
  enable_dns_hostnames = true # VPC内のリソースにパブリックDNSホスト名を自動割り当て有効
  tags = {
    Name = "vpc-1"
  }
}

# サブネット作成 Public
resource "aws_subnet" "public-subnet-1a" {
  vpc_id                  = aws_vpc.vpc-1.id
  cidr_block              = "172.16.10.0/24"
  map_public_ip_on_launch = true # インスタンスにパブリックIP自動割り当て有効
  availability_zone       = "ap-northeast-1a"
  tags = {
    Name = "public-subnet-1a"
  }
}

# インターネットゲートウェイ作成
resource "aws_internet_gateway" "igw-1" {
  vpc_id = aws_vpc.vpc-1.id
  tags = {
    Name = "vpc-1-igw"
  }
}

# ルートテーブル作成 Public
resource "aws_route_table" "public-rt-1" {
  vpc_id = aws_vpc.vpc-1.id
  tags = {
    Name = "public-rt-1"
  }
}

# ルーティング設定 Public
resource "aws_route" "public-1" {
  route_table_id         = aws_route_table.public-rt-1.id
  gateway_id             = aws_internet_gateway.igw-1.id
  destination_cidr_block = "0.0.0.0/0"
}

# サブネットとルートテーブルの紐付け
resource "aws_route_table_association" "public-1" {
  subnet_id      = aws_subnet.public-subnet-1a.id
  route_table_id = aws_route_table.public-rt-1.id
}
