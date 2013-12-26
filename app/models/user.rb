class User < ActiveRecord::Base
  attr_accessible :contact_number, :email, :first_name, :last_name, :registration_status
  has_many :group_members 
  has_many :groups, through: :group_members

  has_many :transactions

  validates :email, :uniqueness => true
  validates :contact_number, :uniqueness => true, :presence => true

  def full_name
  	first_name.humanize + " " + last_name.humanize
  end
end
