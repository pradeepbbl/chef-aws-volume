#
# Cookbook Name:: aws_volume
# Recipe:: default
#
#

chef_gem "aws-sdk" do
  version node['aws_volume']['aws_sdk_version']
  action :install
end

require 'aws-sdk'

aws_volume_ebs_volume "db_ebs_volume" do
    volume_id "vol-7a595d7f"
    data_bag [ "EC2", "key" ]
    action [ :snapshot ]
end