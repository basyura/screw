class AddTitleToStocks < ActiveRecord::Migration
  def self.up
    add_column :stocks , :title , :string
  end

  def self.down
  end
end
