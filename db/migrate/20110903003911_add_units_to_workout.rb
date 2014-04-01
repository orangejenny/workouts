class AddUnitsToWorkout < ActiveRecord::Migration
  def self.up
    add_column :workouts, :unit, :string
    rename_column :workouts, :meters, :distance
  end

  def self.down
    remove_column :workouts, :unit
    rename_column :workouts, :distance, :meters
  end
end
