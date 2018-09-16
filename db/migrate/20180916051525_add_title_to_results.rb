class AddTitleToResults < ActiveRecord::Migration[5.2]
  def change
    add_column :results, :title, :text
  end
end
