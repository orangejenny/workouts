class Day < ActiveRecord::Base
  has_many :workouts, :dependent => :destroy

  validates_presence_of :day
  validates_uniqueness_of :day

	def day_string
		if (self.day.nil?)
			return nil
		end
    text = Date::ABBR_DAYNAMES[self.day.wday] + " " + self.day.month.to_s + "/" + self.day.day.to_s
    if (self.day.year < Date.today.year)
      text = text + "/" + (self.day.year % 100).to_s.rjust(2, "0")
    end 
    text
	end

	def day_string=(day_string)
		self.day = Time.parse(day_string)
	end
end
