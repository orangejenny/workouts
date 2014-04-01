class RenameTypeColumn < ActiveRecord::Migration
  def self.up
    rename_column(:workouts, :type, :activity)
  end

  def self.down
    rename_column(:workouts, :activity, :type)
  end
end
