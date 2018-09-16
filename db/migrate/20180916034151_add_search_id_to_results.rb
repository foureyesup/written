class AddSearchIdToResults < ActiveRecord::Migration[5.2]
  def change
    add_column :results, :search_id, :integer
  end
end
