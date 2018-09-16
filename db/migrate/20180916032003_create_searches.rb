class CreateSearches < ActiveRecord::Migration[5.2]
  def change
    create_table :searches do |t|
      t.datetime :date_executed
      t.integer :user_id
      t.integer :publication_id

      t.timestamps
    end
  end
end
