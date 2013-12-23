class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :description
      t.text :details
      t.float :amount
      t.integer :user_id
      t.integer :group_id
      t.integer :group_member_id

      t.timestamps
    end
  end
end
