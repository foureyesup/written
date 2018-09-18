class AddEstimatedPublishedDateToResults < ActiveRecord::Migration[5.2]
  def change
    add_column :results, :estimated_published_date, :datetime
  end
end
