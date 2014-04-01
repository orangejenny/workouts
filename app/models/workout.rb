class Workout < ActiveRecord::Base
	include ActionView::Helpers::NumberHelper		# for number_with_precision
	METERS_PER_MILE = 1609
	METERS_PER_KILOMETER = 1000
	DISTANCE_UNITS = {
		"m" => "meters",
		"km" => "km",
		"mi" => "miles"
	}
	RANKED_ACTIVITIES = ["erging", "running", "swimming", "biking", "lifting", "other"]

  belongs_to :day

	attr_accessor :seconds, :minutes, :hours

	before_save :set_time

  validates_presence_of :activity, :day_id
  validates_numericality_of :distance, :weight, :allow_blank => true
  validates_numericality_of :time, :sets, :reps, :hours, :minutes, :seconds, :only_integer => true, :allow_blank => true
  validates_inclusion_of :unit, :in => DISTANCE_UNITS.keys, :if => Proc.new { |w| !w.distance.blank? }

	def seconds
		self.time.nil? ? nil : self.time % 60
	end

	def minutes
		self.time.nil? ? nil : ((self.time % 3600) / 60).floor
	end

	def hours
		self.time.nil? ? nil : (self.time / 3600).floor
	end

	def total_distance
		total_value(self.distance)
	end

	def total_time
		total_value(self.time)
	end

	def is_erg
		return Workout.is_erg(self.activity)
	end

	def is_run
		return Workout.is_run(self.activity)
	end

	def might_have_pace
		return self.is_erg || self.is_run || self.activity =~ /^bik/i
	end

	def self.is_erg(string)
		return string =~ /^erg/i
	end

	def self.is_run(string)
		return string =~ /^(run|treadmill)/i
	end

	def time_to_string(time, options = {})
      hours = (time / 3600).floor
      minutes = ((time - hours * 3600) / 60).floor
      seconds = time % 60
      text = ""
      if (hours > 0)
        text = text + hours.to_s + ":" 
        if (minutes < 10) 
          text = text + "0" 
        end 
      end 
      text = text + minutes.to_s + ":" 
      if (seconds < 10) 
        text = text + "0" 
      end 
      text = text + seconds.to_s
      text
  end 

  def pace
    if (self.time.blank? || self.distance.blank?)
      return 0
    end 

    if (self.is_erg)
      distance = Workout.convert_distance(self.distance, self.unit, "m");
      pace = self.time / distance * 500;
			pace = (pace * 10 + 0.5).floor() / 10.0
    else
      distance = Workout.convert_distance(self.distance, self.unit, "mi");
      pace = self.time / distance;
    	pace = (pace + 0.5).floor()
    end 
		pace
  end 

	def pace_string
		suffix = "/"
		if (self.is_erg) 
			suffix = suffix + "500m"
		else
			suffix = suffix + "mi"
		end

		time_to_string(self.pace).sub(/(\.[0-9])[0-9]*/, "\\1") + suffix
	end

	def detail_string
    text = ""
    if (!self.sets.blank?)
      text = text + " " + self.sets.to_s + " x"
    end 
    if (!self.reps.nil?)
      text = text + " " + self.reps.to_s
      if (!self.distance.blank? || !self.time.blank?) 
        text = text + " x"
      end 
    end 
    if (!self.distance.nil?)
      text = text + " " + number_display(self.distance) + " " + self.unit
      if (!self.time.blank?)
        text = text + " in"
      end 
    end 
    if (!self.time.nil?)
      text = text + " " + time_to_string(self.time)
      if (self.might_have_pace && !self.distance.blank?)
        text = text + " (" + self.pace_string + ")" 
      end 
    end 
    if (!self.weight.nil?)
      text = text + " @ " + number_display(self.weight) + "lb"
    end 
    text.strip
  end 

  def number_display(number)
    number_with_precision(number, :strip_insignificant_zeros => true, :delimiter => ",")
  end

	def set_time
		self.time = 0
		if (!@hours.nil?)
			self.time = self.time + @hours.to_i * 3600
		end
		if (!@minutes.nil?)
			self.time = self.time + @minutes.to_i * 60
		end
		if (!@seconds.nil?)
			self.time = self.time + @seconds.to_i
		end
		if (self.time == 0)
			self.time = nil
		end
	end

	# gets distinct activites across all workouts
	def self.activities
		workouts = Workout.find(
			:all, 
			:select => "activity, count(*) count", 
			:group => "activity",
			:order => "count desc"
		)
		workouts.map { |w| w.activity }
	end

	# this is for graphing, so if getting a specific activity, it only gets workouts with either a time or a distance
	def self.get_workouts(activity, amount_ago, unit_ago)
		conditions = []
		binds = {}
		if (!activity.blank?)
			conditions.push("(distance is not null or time is not null)")
			conditions.push("activity = :activity")
			binds[:activity] = activity
		end
		if (!amount_ago.blank?)
			conditions.push("days.day >= :time_ago")
			binds[:time_ago] = Time.now.advance(unit_ago.to_sym => -1 * amount_ago.to_i)
		end
		Workout.find(:all, 
			:joins => :day, 
			:conditions => [conditions.join(" and "), binds],
			:order => "days.day asc"
		)
	end

	protected

	def total_value(value)
		if (value.blank?)
			return 0
		end
		if (!self.reps.blank?)
			value = value * self.reps
		end
		if (!self.sets.blank?)
			value = value * self.sets
		end
		value
	end

	def self.convert_distance(distance, unit, desired_unit)
		if (!DISTANCE_UNITS.keys.include?(unit) || !DISTANCE_UNITS.keys.include?(desired_unit))
			raise RuntimeError, sprintf("Either unit (%s) or desired_unit (%s) is invalid", unit, desired_unit)
		end

		if (unit == desired_unit)
			return distance
		end

		case unit
			when "m"
				case desired_unit
					when "km"
						distance = distance / METERS_PER_KILOMETER
					when "mi"
						distance = distance / METERS_PER_MILE
				end
			when "km"
				distance = distance * METERS_PER_KILOMETER
				if (desired_unit == "mi")
					distance = distance / METERS_PER_MILE
				end
			when "mi"
				distance = distance * METERS_PER_MILE
				if (desired_unit == "km")
					distance = distance * METERS_PER_MILE / METERS_PER_KILOMETER
				end
		end
		distance
	end
end
