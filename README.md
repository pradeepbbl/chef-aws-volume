
[![Build Status](https://secure.travis-ci.org/unixworld/chef-aws-volume.png)](http://travis-ci.org/unixworld/chef-aws-volume)
[![Version](http://img.shields.io/badge/cookbook-0.1.5-blue.svg)](https://github.com/unixworld/chef-aws-volume)

Description
===========

This cookbook provides libraries, resources and providers to configure
and manage Amazon Web Services components and offerings with the EC2
API. Currently supported resources:

* EBS Volumes (`ebs_volume`)

Requirements
============

Requires Chef 10.X or higher for Lightweight Resource and Provider
support. Chef 11+ is recommended. While this cookbook can be used in
`chef-client` with a Chef Server.

An Amazon Web Services account is required. The Access Key and Secret
Access Key are used to authenticate with EC2 or an instance with IAM role recommended.

AWS Credentials
===============

In order to manage AWS components, authentication credentials need to
be available to the node. There are 2 way to handle this:
* Load credentials from data bag (only support encrypted databag)
* explicitly pass credentials parameter to the resource
* or let the resource pick up credentials from the IAM role assigned to the instance


Recipes
=======

default.rb
----------

The default recipe installs the `aws_sdk` RubyGem, which this
cookbook requires in order to work with the aws API. Make sure that
the aws recipe is in the node or role `run_list` before any resources
from this cookbook are used.

    "run_list": [
      "recipe[aws_volume]"
    ]

The `gem_package` is created as a Ruby Object and thus installed
during the Compile Phase of the Chef run.

Libraries
=========

The cookbook has a library module, `AWS::Ec2`, which can be
included where necessary:

    include Aws::Ec2

This is needed in any providers in the cookbook. Along with some
helper methods used in the providers, it sets up a class variable,
`ec2` that is used along with the access and secret access keys

Resources and Providers
=======================

This cookbook provides one resources and corresponding providers.

## ebs_volume.rb

Manage Elastic Block Store (EBS) volumes with this resource.

Actions:

* `create` - Create a new volume.
* `attach` - Attach the specified volume.
* `snapshot` - Create a snapshot of specified volume.
* `delete_snapshot` - Delete the specified snapshot id.

Attribute Parameters For Action `create`:

* `aws_secret_key`, `aws_access_key` (optional) - passed to
  `AWS:Ec2` to authenticate required, unless using IAM roles for authentication.
* `size` - size of the volume in gigabytes.
* `snapshot_id` (optional) - snapshot to build EBS volume from.
* `device` (optional) - local block device to attach the volume to, e.g.
  `/dev/sdi` but no default value, required. used when both create and attach action called in same recipe.
* `volume_type` (optional) - "standard", "io1" (io1 is the type for IOPS volume) or "gp2". Default was set to standard.
* `iops` - number of Provisioned IOPS to provision, must be >= 100. Default was set to 0
* `data_bag` (optional) - provide data bag and key details to load AWS credentials. eg: data_bag["NAME", "Key"] 

* Example of Volume create recipe

The below recipe will create a new volume from snapshot_id 'snap-XXXX' and attached to the instance as '/dev/sdb'

	aws_volume_ebs_volume "db_ebs_volume" do
 		snapshot_id "snap-XXXX"
 		device "/dev/sdb"
 		action [ :create, :attach ]
	end 

The below recipe will create a new gp2 volume with size 1G and attached to the instance as '/dev/sda'

	aws_volume_ebs_volume "db_ebs_volume" do
		size 1
		device "/dev/sda"
		volume_type "gp2"
 		action [ :create, :attach ]
	end

The below recipe will create a new volume with size 1G

	aws_volume_ebs_volume "db_ebs_volume" do
		size 1
 		action [ :create ]
	end


The below recipe will take AWS access and secret key from data bag
	
	aws_volume_ebs_volume "db_ebs_volume" do
		size 1
		device "/dev/sda"
		data_bag [ "EC2", "key" ]
 		action [ :create, :attach ]
	end

Attribute Parameters For Action `attach`:

* `aws_secret_key`, `aws_access_key` (optional) - passed to
  `AWS:Ec2` to authenticate required, unless using IAM roles for authentication
* `data_bag` (optional) - provide data bag and key details to load AWS credentials. eg: data_bag["NAME", "Key"] 
* `device` - local block device to attach the volume to, e.g. `/dev/sdi`
* `volume_id` - ID of the volume which need to be attached.

* Example of Volume attach recipe

The below recipe will only attach the the given vloume id 
	
	aws_volume_ebs_volume "db_ebs_volume" do
		volume_id "vol-XXXXXX"
		device "/dev/sdb"
		action [ :attach ]
	end

Attribute Parameters For Action `snapshot`:

* `aws_secret_key`, `aws_access_key` (optional) - passed to
  `AWS:Ec2` to authenticate required, unless using IAM roles for authentication
* `data_bag` (optional) - provide data bag and key details to load AWS credentials. eg: data_bag["NAME", "Key"] 
* `volume_id` - ID of the volume which need to be attached.
* `description` - Description used to tag snapshot.


The below recipe will create a snapshot of mentioned volume
	
	aws_volume_ebs_volume "db_ebs_volume" do
    	volume_id "vol-XXXXXXX"
    	description "Test snapshot"
    	data_bag [ "EC2", "key" ]
    	action [ :snapshot ]
	end

Attribute Parameters For Action `delete_snapshot`:

* `aws_secret_key`, `aws_access_key` (optional) - passed to
  `AWS:Ec2` to authenticate required, unless using IAM roles for authentication
* `data_bag` (optional) - provide data bag and key details to load AWS credentials. eg: data_bag["NAME", "Key"] 
* `snapshot_id` - snapshot id to delete.

The below recipe will delete the mentioned snapshot
	
	aws_volume_ebs_volume "db_ebs_volume" do
    	snapshot_id "snap-XXXXX"
    	data_bag [ "EC2", "key" ]
    	action [ :delete_snapshot ]
	end



Please raise issue/feature on github https://github.com/unixworld/chef-aws-volume/issues.
