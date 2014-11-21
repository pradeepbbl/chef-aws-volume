include AWS::Ec2

require 'open-uri'

action :create do	
	# Check if snapshot id present
	if new_resource.snapshot_id =~ /snap-*/
		Chef::Log.debug "Fetch snapshot_id #{new_resource.snapshot_id}"
		snapshot_id = findSnapshot(new_resource.snapshot_id)
		Chef::Log.debug "snapshot_id #{snapshot_id}"
		ec2Create(new_resource.size, new_resource.device, new_resource.volume_type, new_resource.snapshot_id)
	else
		snapshot_id = nil
		ec2Create(new_resource.size, new_resource.device, new_resource.volume_type, snapshot_id)
	end
	#Notify observers
	new_resource.updated_by_last_action(true)
end


action :attach do
	# Attach volume
	volume = ec2.volumes[new_resource.volume_id]
	device = new_resource.device
	action = new_resource.action
	instances_id = getInstanceId()

	if action.include?(:create)
		Chef::Log.debug "Attach action called via :create or volume is empty"
	else
		attach = ec2Attach(volume, instances_id, device)

		if attach == "success"
			Chef::Log.info "Volume with ID #{new_resource.volume_id} has been attached to Instance with ID #{instances_id}"
		else
			raise "Volume attach failed ..!"
		end
	end
	
	#Notify observers
	new_resource.updated_by_last_action(true)
end

action :snapshot do
	# Take snapshot of given volume id.
	success, snapshot_id = ec2TakeSanp(new_resource.dry_run, new_resource.volume_id, new_resource.description)

	if success
		Chef::Log.info "Volume with ID #{new_resource.volume_id} has been attached to Instance with ID #{instances_id}"
	else
		raise "Can't take Snapshot!"
	end
end

# Volume create function 
def ec2Create(size="", device="", volume_type="", snapshot="")
	
	# Get Instance ID and zone details
	zone = getZone()
	instances_id = getInstanceId()

	if !snapshot.nil?
		volume = ec2.volumes.create(:availability_zone => zone, :volume_type => volume_type,
									:snapshot_id => snapshot)

		sleep 1 until volume.status == :available
		
		action = new_resource.action
		
		if action.include?(:attach)
			Chef::Log.debug "Action contain attach"
			attachment = ec2Attach(volume, instances_id, device)
			
			if attachment == "success"
				Chef::Log.info "Volume created in host #{instances_id} on zone #{zone} form snapshot #{snapshot} and attached to device #{device}"
			else
				raise "Error while attaching volume"
			end
		else
			Chef::Log.info "Volume created in host #{instances_id} on zone #{zone} form snapshot #{snapshot}"
		end
	else
		volume = ec2.volumes.create(:size => size, :volume_type => volume_type,
									:availability_zone => zone)

	  sleep 1 until volume.status == :available	
		
		action = new_resource.action

		if action.include?(:attach)
			Chef::Log.debug "Action contain attach"
			attachment = ec2Attach(volume, instances_id, device)
			if attachment == "success"
				Chef::Log.info "Volume created in host #{instances_id} on zone #{zone} with size #{size} and attached to device #{device}"
			else
				raise "Error while attaching volume"
			end	
		else
			Chef::Log.info "Volume created in host #{instances_id} with size #{size} on zone #{zone}"
		end
	end
end

# Volume attach function
def ec2Attach(volume="", instances_id="", device="")
	unless device.nil?
		Chef::Log.debug "Device not null!"
		attach = volume.attach_to(ec2.instances[instances_id], device)
		sleep 1 until attach.status != :attaching
		return "success"
	else
		Chef::Log.error "Sorry can't attach volume without device, please pass device value in recipe!"
		raise "Volume with empty device name can't attach, please pass device value in recipe! "
	end
end


# Volume create snapshot function

def ec2TakeSanp(dry_run="", volume="", description="")
	unless volume.nil?
		# Take snapshot of given volume ID
		snapshot = ec2.create_snapshot(:dry_run => dry_run, :volume_id => volume, :description => description)
		chef::Log.info snapshot.progress until snapshot.status != :done
		return [true, snapshot.snapshot_id]
	else
		Chef::Log.error "Sorry can't create snapshot with empty volume_id, please pass volume_id value in recipe!"
		raise "Sorry can't create snapshot with empty volume_id, please pass volume_id value in recipe!"
	end
end
