class CreatePublications < ActiveRecord::Migration[5.2]
  def change
    create_table :publications do |t|
      t.text :name
      t.string :root_url

      t.timestamps
    end
  end
end
