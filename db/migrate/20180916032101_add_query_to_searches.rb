class AddQueryToSearches < ActiveRecord::Migration[5.2]
  def change
    add_column :searches, :query, :text
  end
end
