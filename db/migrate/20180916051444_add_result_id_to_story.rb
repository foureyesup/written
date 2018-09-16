class AddResultIdToStory < ActiveRecord::Migration[5.2]
  def change
    add_column :stories, :result_id, :integer
  end
end
