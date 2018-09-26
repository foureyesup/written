class AddSearchIdToStories < ActiveRecord::Migration[5.2]
  def change
    add_column :stories, :search_id, :integer
  end
end
