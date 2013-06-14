class CreateWebsocketSessions < ActiveRecord::Migration
  def change
    create_table :websocket_sessions do |t|
      t.string :address
      t.integer :group_id
      t.integer :sid

      t.timestamps
    end
  end
end
