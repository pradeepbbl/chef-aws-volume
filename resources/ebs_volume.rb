actions :create, :attach, :snapshot

state_attrs :size,
			:snapshot_id,
			:volume_type,
			:iops,
			:device,
			:aws_access_key,
			:aws_secret_key,
			:volume_id,
			:data_bag,
			:description,
			:dry_run

attribute :size, :kind_of => Integer
attribute :snapshot_id, :kind_of => String
attribute :device, :kind_of => String
attribute :aws_access_key, :kind_of => String
attribute :aws_secret_key, :kind_of => String
attribute :volume_type, :kind_of => String, :default => 'standard'
attribute :volume_id, :kind_of => String
attribute :iops, :kind_of => Integer, :default => 0
attribute :data_bag, :kind_of => Array
attribute :description, :kind_of => String
attribute :dry_run, :kind_of => Boolean, :default => True

def initialize(*args)
  super
  @action = :create
end