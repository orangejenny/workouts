class WorkoutsController < ApplicationController
  # GET /workouts/new
  def new
    @workout = Workout.new
		@workout.day_id = params[:day_id]
		@day = Day.find(@workout.day_id)

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /workouts/1/edit
  def edit
    @workout = Workout.find(params[:id])
		@day = Day.find(@workout.day_id)
  end

  # POST /workouts
  def create
		@day = Day.find(params[:workout][:day_id])
    @workout = Workout.new(params[:workout])

    respond_to do |format|
      if @workout.save
				flash[:notice] = 'Workout was successfully created.'
        format.html { redirect_to(:controller => "days", :action => "index") }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /workouts/1
  def update
		@day = Day.find(params[:workout][:day_id])
    @workout = Workout.find(params[:id])

    respond_to do |format|
      if @workout.update_attributes(params[:workout])
				flash[:notice] = 'Workout was successfully updated.'
        format.html { redirect_to(:controller => "days", :action => "index") }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /workouts/1
  def destroy
    @workout = Workout.find(params[:id])
    @workout.destroy

    respond_to do |format|
			flash[:notice] = "Workout deleted."
      format.html { redirect_to(days_url) }
    end
  end
end
