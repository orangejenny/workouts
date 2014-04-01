class BackupsController < ApplicationController
	def get_backup
		days = Day.find(:all, :include => :workouts, :order => "day desc")
		lines = []
		days.each do |d|
			d.workouts.each do |w|
				lines.push(d.day_string + " " + w.activity + " " + w.detail_string)
			end
		end

		t = Date.today
		date_string = Date.today.year.to_s
		date_string = date_string + Date.today.month.to_s.rjust(2, "0")
		date_string = date_string + Date.today.day.to_s.rjust(2, "0")
		send_data lines.join("\n"), :type => "text/plain", :filename => "workouts_backup_" + date_string + ".txt", :disposition => "attachment"

		Backup.create!
	end

	def self.latest
		backup = Backup.find(:first, :order => "created_at desc")
		backup.created_at
	end
end
