class AddXpathToPages < ActiveRecord::Migration
  def self.up
    add_column :pages , :xpath , :string
  end

  def self.down
    remove_column :pages , :xpath
  end
end
