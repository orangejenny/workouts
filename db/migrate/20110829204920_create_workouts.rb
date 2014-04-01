class CreateWorkouts < ActiveRecord::Migration
  def self.up
    create_table :workouts do |t|
      t.string :type
      t.integer :time
      t.float :meters
      t.integer :sets
      t.integer :reps
      t.float :weight
      t.integer :day_id

      t.timestamps
    end
  end

  def self.down
    drop_table :workouts
  end
end
