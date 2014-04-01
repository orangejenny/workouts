class AddUserToDays < ActiveRecord::Migration
  def self.up
		add_column :days, :user, :string
  end

  def self.down
		remove_column :days, :user
  end
end
