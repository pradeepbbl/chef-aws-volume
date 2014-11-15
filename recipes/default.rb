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

# Create Volume with snapshot id
# aws_volume_ebs_volume "db_ebs_volume" do
# 	size 5
# 	device "/dev/sdb"
# 	action [ :create, :attach ]
# end

# # Create new Volume
 # aws_volume_ebs_volume "db_ebs_volume" do
 #  	size 1
 # 	device "/dev/sde"
 #  	action [ :create, :attach ]
 # end

# Attach a volume
# aws_volume_ebs_volume "db_ebs_volume" do
#  	volume_id "vol-d6af1dd3"
#  	device "/dev/sdb"
#  	action [ :attach ]
# end

# aws_volume_ebs_volume "db_ebs_volume" do
# 	data_bag [ "EC2", "key" ]
#  	action [ :test ]
# end