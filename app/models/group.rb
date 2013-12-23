class Group < ActiveRecord::Base
#  attr_accessible :description, :group_admin_id, :name
  has_many :group_members
  has_many :users, through: :group_members

  has_many :transactions
end
