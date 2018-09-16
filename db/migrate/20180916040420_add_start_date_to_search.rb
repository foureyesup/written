class AddStartDateToSearch < ActiveRecord::Migration[5.2]
  def change
    add_column :searches, :start_date, :datetime
  end
end
