class DaysController < ApplicationController
	def login
		respond_to do |format|
			format.html
		end
	end

  # GET /days
  def index
		@amount_ago = params[:amount_ago]
		@unit_ago = params[:unit_ago]
		conditions = []
		binds = {}
		if (!params[:activity].blank?)
			conditions.push("workouts.activity = :activity")
			binds[:activity] = params[:activity]
		end
		if (@amount_ago.blank?)
			@amount_ago = 3
		end
		if (@unit_ago.blank?)
			@unit_ago = "months"
		end
		conditions.push("days.day >= :time_ago")
		binds[:time_ago] = Time.now.advance(@unit_ago.to_sym => -1 * @amount_ago.to_i)
    @days = Day.find(:all, 
			:include => :workouts, 
			:conditions => [conditions.join(" and "), binds], 
			:order => "day desc"
		)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /days/new
  def new
    @day = Day.new
		@day.day = Time.now

    respond_to do |format|
      format.html # new.html.erb
    end
  end

	def show
		@day = Day.new

		respond_to do |format|
			format.html { redirect_to(days_path) }
		end
	end

  # GET /days/1/edit
  def edit
    @day = Day.find(params[:id])
  end

  # POST /days
  def create
    @day = Day.new(params[:day])

    respond_to do |format|
      if @day.save
				flash[:notice] = 'Day was successfully created.'
        format.html { redirect_to(:controller => "workouts", :action => "new", :day_id => @day.id) }
      else
				render :action => 'new'
      end
    end
  end

  # PUT /days/1
  def update
    @day = Day.find(params[:id])

    respond_to do |format|
      if @day.update_attributes(params[:day])
				flash[:notice] = 'Day was successfully updated.'
        format.html { redirect_to(days_path) }
      else
        render :action => "edit"
      end
    end
  end

  # DELETE /days/1
  def destroy
    @day = Day.find(params[:id])
    @day.destroy

    respond_to do |format|
			flash[:notice] = "Day and workouts deleted."
      format.html { redirect_to(days_url) }
    end
  end
end
