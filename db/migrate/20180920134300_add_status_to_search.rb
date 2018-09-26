class AddStatusToSearch < ActiveRecord::Migration[5.2]
  def change
    add_column :searches, :status, :text
  end
end
