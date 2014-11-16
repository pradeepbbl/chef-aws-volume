include AWS::Ec2

require 'open-uri'

action :create do	
	# Check if sanpshot id present
	if new_resource.snapshot_id =~ /snap-*/
		Chef::Log.debug "Featch snapshot_id #{new_resource.snapshot_id}"
		snapshot_id = findSnapshot(new_resource.snapshot_id)
		Chef::Log.debug "snapshot_id #{snapshot_id}"
		ec2Create(new_resource.size, new_resource.device, new_resource.snapshot_id)
	else
		snapshot_id = nil
		ec2Create(new_resource.size, new_resource.device, snapshot_id)
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

# create volume 
def ec2Create(size="", device="", snapshot="")
	
	# Get Instance ID and zone details
	zone = getZone()
	instances_id = getInstanceId()

	if !snapshot.nil?
		volume = ec2.volumes.create(:availability_zone => zone,
									:snapshot_id => snapshot)

		unless volume.status == :available
			sleep 1
		end


		action = new_resource.action
		
		if action.include?(:attach)
			Chef::Log.debug "Action contain attach"
			attachment = ec2Attach(volume, instances_id, device)
			
			if attachment == "success"
				Chef::Log.info "Volume created in host #{instances_id} on zone #{zone} form snapshot #{snapshot} and attached to device #{device}"
				Chef::Log.info "Attach obj #{attachment}"
			else
				raise "Error while attaching volume"
			end
		else
			Chef::Log.info "Volume created in host #{instances_id} on zone #{zone} form snapshot #{snapshot}"
		end
	else
		Chef::Log.debug "creating new volume line 30"
		volume = ec2.volumes.create(:size => size,
									:availability_zone => zone)

		unless volume.status == :available
			sleep 1
		end
		
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

# Attach volume
def ec2Attach(volume="", instances_id="", device="")
	attach = volume.attach_to(ec2.instances[instances_id], device)
	sleep 1 until attach.status != :attaching
	Chef::Log.info "Device name in instance is #{attach.device}"
	return "success"
end
