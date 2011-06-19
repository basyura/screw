class CreateStocks < ActiveRecord::Migration
  def self.up
    create_table :stocks do |t|
      t.string  :url
      t.integer :user_id
      t.integer :read

      t.timestamps
    end
  end

  def self.down
    drop_table :stocks
  end
end
