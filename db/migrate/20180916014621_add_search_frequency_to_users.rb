class AddSearchFrequencyToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :search_frequency_days, :integer
  end
end
