class AddEstimatedAuthorToResult < ActiveRecord::Migration[5.2]
  def change
    add_column :results, :estimated_author, :text
  end
end
