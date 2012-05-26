class CreateUserServiceDetails < ActiveRecord::Migration
  def change
    create_table :user_service_details do |t|
      
      t.timestamps
    end
  end
end
