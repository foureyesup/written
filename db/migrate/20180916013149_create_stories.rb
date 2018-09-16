class CreateStories < ActiveRecord::Migration[5.2]
  def change
    create_table :stories do |t|
      t.integer :publication_id
      t.integer :user_id
      t.text :story_url
      t.text :title
      t.datetime :date_published
      t.text :lede

      t.timestamps
    end
  end
end
