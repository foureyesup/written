class CreateResults < ActiveRecord::Migration[5.2]
  def change
    create_table :results do |t|
      t.text :url
      t.text :display_url
      t.datetime :date_last_crawled
      t.text :snippet
      t.string :language
      t.integer :user_id
      t.integer :publication_id

      t.timestamps
    end
  end
end
