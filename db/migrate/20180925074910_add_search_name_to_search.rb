class AddSearchNameToSearch < ActiveRecord::Migration[5.2]
  def change
    add_column :searches, :search_name, :text
    add_column :searches, :search_url, :text
  end
end
