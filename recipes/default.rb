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

# aws_volume_ebs_volume "db_ebs_volume" do
#     volume_id "vol-75737270"
#     description "Test snapshot"
#     data_bag [ "EC2", "key" ]
#     action [ :snapshot ]
# end

aws_volume_ebs_volume "db_ebs_volume" do
    snapshot_id "snap-5eb9dad3"
    data_bag [ "EC2", "key" ]
    action [ :delete_snapshot ]
end
