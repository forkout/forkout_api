class Transaction < ActiveRecord::Base
#  attr_accessible :amount, :description, :details, :group_id, :group_member_id, :user_id
  belongs_to :user
  belongs_to :group

  belongs_to :group_member

  has_many :group_members
  has_many :users, through: :group_members


  validates :user_id, :presence => true
  validates :group_id, :presence => true
end
