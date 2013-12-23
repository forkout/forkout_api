class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :contact_number
      t.string :registration_status

      t.timestamps
    end
  end
end
