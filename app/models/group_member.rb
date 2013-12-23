class GroupMember < ActiveRecord::Base
#  attr_accessible :group_id, :user_id
  belongs_to :user
  belongs_to :group

  has_many :transactions
end
