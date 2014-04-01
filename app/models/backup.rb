class Backup < ActiveRecord::Base
	def self.last_backup
		latest_backup = Backup.find(:first, :order => "created_at desc")
		latest_backup.created_at
	end

	def self.time_for_backup
		return self.last_backup < 30.days.ago
	end
end
