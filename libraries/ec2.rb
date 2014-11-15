# Global library to make request to AWS service using aws-sdk

begin
  require 'rubygems'
  require 'open-uri'
rescue LoadError
  raise "Missing gem 'aws-sdk', 'rubygems' or 'open-uri'"
end


module AWS
	module Ec2
		
		def ec2
			# Create AWS interface
			@@ec2 ||= create_aws_interface()
      	end

      	def create_aws_interface()
      		
      		region = getZone()
      		region = region[0, region.length-1]

      		if new_resource.aws_access_key and new_resource.aws_secret_key
      			Chef::Log.info "Region is #{region}"
      			AWS::EC2.new(
      				:access_key_id => new_resource.aws_access_key,
      				:secret_access_key => new_resource.aws_secret_key,
      				:region => region)
      		elsif new_resource.data_bag
      			Chef::Log.debug "Loading key from DataBag using secret file #{node['chef']['secretfile']}"
      			Chef::Log.debug  "Check  #{new_resource.data_bag}"
      			
      			bag = new_resource.data_bag[0]
      			key = new_resource.data_bag[1]

      			my_secret = Chef::EncryptedDataBagItem.load_secret("#{node['chef']['secretfile']}")
      			data_bag = Chef::EncryptedDataBagItem.load(bag, key, my_secret)
      			
      			aws_access_key = data_bag["aws_access_key"]
      			aws_secret_key = data_bag["aws_secret_access_key"]
      			
      			Chef::Log.debug "AWS access key is #{aws_access_key} and secret key is #{aws_secret_key}"

      			AWS::EC2.new(
      				:access_key_id => aws_access_key,
      				:secret_access_key => aws_secret_key,
      				:region => region)
      		else
      			AWS::EC2.new(:region => region)
      		end
      	end

   		

		# Get snapshot id
		def findSnapshot(vol_id="")
			snapshot_id = nil
			
			ec2.snapshots.each do |snapshot|
				# puts snapshot.inspect
				if snapshot.id == vol_id
					snapshot_id = snapshot.id
				end
			end

			raise "Cannot find snapshot id!" unless snapshot_id
			Chef::Log.info("Snapshot ID is #{snapshot_id}")
        	return snapshot_id
		end

		# Get instance ID
		def getInstanceId()
			instance_id = open('http://169.254.169.254/latest/meta-data/instance-id'){|f| f.gets}
			raise "Cannot find instance id!" unless instance_id
			#Chef::Log.debug("Instance ID is #{instance_id}")
			return instance_id	
		end

		# Get zone
		def getZone()
			availability_zone = open('http://169.254.169.254/latest/meta-data/placement/availability-zone/'){|f| f.gets}
    		raise "Cannot find availability zone!" unless availability_zone
    		#Chef::Log.debug("Instance's availability zone is #{availability_zone}")
    		return availability_zone
    	end
	end
end