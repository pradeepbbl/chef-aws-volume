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
