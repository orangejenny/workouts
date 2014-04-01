module WorkoutsHelper
  def graph_data(activity, amount_ago, unit_ago)
    workouts = Workout.get_workouts(activity, amount_ago, unit_ago)
		if (workouts.length == 0)
			return []
		end

    if (Workout.is_run(activity))
      points = []
      workouts.each do |w| 
        x = w.distance.blank? ? 0 : Workout.convert_distance(w.total_distance, w.unit, "mi")
        y = w.total_time
        points.push([x, y]) 
      end 
    elsif (Workout.is_erg(activity))
      points = {}
      workouts.each do |w| 
 	      distance = w.distance.blank? ? 0 : Workout.convert_distance(w.total_distance, w.unit, "km")
				# Only graph standard erg distances: 2K, 6K, 10K
				if (![2, 6, 10].include?(distance))
					next
				end
				# As this one's a line graph, skip anything missing a time
				if (w.time.blank?)
					next
				end
				distance = distance_to_label(distance)
       	if (points[distance].nil?)
     	    points[distance] = []
   	    end 
  	    day = w.day.day
	      points[distance].push([Time.utc(day.year, day.month, day.day).tv_sec * 1000, w.pace])
      end 
		else
			# cut workouts down to at most one per day, choosing the highest-ranked one (Workout::RANKED_ACTIVITIES)
			days = {}
			first_monday = Time.now.monday
			activity_rank = Workout::RANKED_ACTIVITIES
			workouts.each do |w|
				if (activity_rank.include?(w.activity))
					activity = w.activity
				elsif (!w.weight.nil?)
					activity = "lifting"
				else
					activity = "other"
				end
				if (days[w.day.day].nil?)
					days[w.day.day] = activity_rank.index(activity)
				else
					days[w.day.day] = [days[w.day.day], activity_rank.index(activity)].min
				end
				if (first_monday > w.day.day.monday)
					first_monday = w.day.day.monday
				end
			end

			# initialize frequency data
			monday_count = (Time.now.monday.to_date - first_monday) / 7
			data = []
			(0..monday_count).to_a.each do |index|
				data[index] = {}
				activity_rank.each do |activity|
					data[index][activity] = 0
				end
			end

			# populate frequency data
			days.each do |day, rank|
				activity = activity_rank[rank]
				
				monday_index = (day.monday - first_monday) / 7
				if (data[monday_index][activity].nil?)
					data[monday_index][activity] = 0
				end
				data[monday_index][activity] = data[monday_index][activity] + 1
			end

			# build array of graph points
			points = {}
			data.each_with_index do |activities, monday_index|
				activities.each do |activity, count|
					if (points[activity].nil?)
						points[activity] = []
					end
					points[activity].push([monday_index, count])
				end
			end
    end 

    points
  end 

  def graph_tooltips(activity, amount_ago, unit_ago)
    workouts = Workout.get_workouts(activity, amount_ago, unit_ago)
    points = activity =~ /^run/i ? [] : {}
    workouts.each do |w| 
      text = w.day.day_string + " " + w.detail_string
			if (activity =~ /^run/i) 
				points.push(text)
			else 
				distance = distance_to_label(Workout.convert_distance(w.total_distance, w.unit, "km"))
				if (points[distance].nil?)
					points[distance] = []
				end
				points[distance].push(text)
			end
    end 
    points
  end 

	def distance_to_label(distance)
		distance.to_s.sub(".0", "") + "k"
	end

	def workout_links(workout)
		text = "<span style='float: right; white-space: nowrap;'>"
    text = text + link_to('(edit)', edit_workout_path(workout))
    text = text + link_to('(x)', workout, :confirm => 'Are you sure?', :method => :delete)
		text = text + "</span>"
		text
  end
end
