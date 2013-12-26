class AddColumnSettledToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :settled, :boolean, :default => 0
  end
end
