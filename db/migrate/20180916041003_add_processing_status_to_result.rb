class AddProcessingStatusToResult < ActiveRecord::Migration[5.2]
  def change
    add_column :results, :processing_status, :string
    add_column :results, :processed_date, :datetime
  end
end
