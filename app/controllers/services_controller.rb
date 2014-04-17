class ServicesController < ApplicationController
  def group_expenses_report
    [:group_id].each do |key|
      unless params[key]
        render json: {status: "failed", message: "missing paramater : #{key}"}
        return
      end
    end
    
    # transactions = Transaction.where(:group_id => 1, :settled => false)
    # total_expences = transactions.map{ |transaction| transaction.amount }.sum
    # amount_paid_by_each_user =  transactions.group_by { |transaction| transaction[:user_id] }.map { |user_id, value| { user_id => value.map {|i| i[:amount]}.inject(:+) } }
    # http://stackoverflow.com/questions/974922/algorithm-to-share-settle-expenses-among-a-group

    data = []
    total_expences = Transaction.where(:group_id => params[:group_id], :settled => false).sum(:amount)
    group = Group.where(:id => params[:group_id]).includes(:group_members, :users).first
    expences_per_head = total_expences / group.total_members_count
    amount_paid_by_each_user = Transaction.where(:group_id => params[:group_id], :settled => false).group(:user_id).sum(:amount)
    group.group_members.each do  |group_member|
      balance = expences_per_head - (amount_paid_by_each_user[group_member[:user_id]] || 0)
      data << { user_id: group_member[:user_id],
                user_name: group_member.user.full_name,
                amount_paid: (amount_paid_by_each_user[group_member[:user_id]] || 0),
                amount_dues: balance.round(2)
              }
    end
    response_object = {
                        status: "success",
                        report: { group_id: params[:group_id],
                                  total_expences: total_expences,
                                  expences_per_head: expences_per_head,
                                  details: data
                                }
                      }

    render json: response_object
  end

  def sign_in
    [:email, :password].each do |key|
      unless params[key]
        render json: {status: "failed", message: "missing paramater : #{key}"}
        return
      end
    end

    user = User.authenticate(params[:email], params[:password])
    if user
      response_object = {
                          status: "success",
                          user: user
                        }
    else
      response_object = {
                          status: "failed",
                          message: "Authentication failed, incorrect email or password"
                        }
    end
    render json: response_object
  end

  def sync_contacts
    [:contacts].each do |key|
      unless params[key]
        render json: {status: "failed", message: "missing paramater : #{key}"}
        return
      end
    end
    contacts = parse(eval(params[:contacts]))
    users = User.where(:contact_number => contacts)
    response_object = {
                        status: "success",
                        total_count: users.count,
                        users: users
                      }
    render json: response_object
  end

  def parse contacts
    contacts.each do |number|
      regex = /\s+|\(|\)|\?|\-|\+91/
      number.gsub!(regex, "") if number =~ regex
    end
    
  end

  def add_group_members
    [:group_id, :group_member_ids ].each do |key|
      unless params[key]
        render json: {status: "failed", message: "missing paramater : #{key}"}
        return
      end
    end
    user_ids = parse(eval(params[:group_member_ids]))
    group = Group.find(params[:group_id])
    if group
      user_ids.each do |user_id|
        user = User.find(user_id)
        group.group_members.create!(user_id: user.id) if user
      end
      response_object = {
                          status: "success"
                        }
    else
      response_object = {
                          status: "failed",
                          message: 'group not found'
                        }

    end

    render json: response_object
      
  end

  def authenticate_user
    [:username, :password].each do |key|
      unless params[key]
        render json: {status: "failed", message: "missing paramater : #{key}"}
        return
      end
    end
    email_regex = /\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/
    if params[:username] =~ email_regex
      user = User.find_by_email_and_password(params[:username], params[:password])
    else
      user = User.find_by_contact_number_and_password(params[:username], params[:password])
    end

    if user
      response_object = {
                          status: "success",
                          user: user
                        }
    else
      response_object = {
                          status: "failed",
                          errors: "username or password doesn't match"
                        }

    end
    render json: response_object
  end

  def get_groups
    [:user_id].each do |key|
      unless params[key]
        render json: {status: "failed", message: "missing paramater : #{key}"}
        return
      end
    end

    user = User.find(params[:user_id])
    if user    
      response_object = {
                          status: "success",
                          groups: user.groups
                        }
    else
      response_object = {
                          status: "failed",
                          errors: "user_id not found"
                        }
    end
    render json: response_object
  end

  def get_group_members
    [:group_id].each do |key|
      unless params[key]
        render json: {status: "failed", message: "missing paramater : #{key}"}
        return
      end
    end

    group = Group.find(params[:group_id])
    if group   
      response_object = {
                          status: "success",
                          group_members: group.users
                        }
    else
      response_object = {
                          status: "failed",
                          errors: "group_id not found"
                        }
    end
    render json: response_object
  end

  def get_all_group_members
    [:group_ids].each do |key|
      unless params[key]
        render json: {status: "failed", message: "missing paramater : #{key}"}
        return
      end
    end
    group_members = []
    group_ids = eval(params[:group_ids])
    group_ids.each do |group_id|
      group = Group.find(group_id)
      group_members << {group_id => group.users} if group
    end

    response_object = {
                        status: "success",
                        group_members: group_members
                      }
      
    render json: response_object
  end

  def get_group_transactions
    [:group_id].each do |key|
      unless params[key]
        render json: {status: "failed", message: "missing paramater : #{key}"}
        return
      end
    end

    group = Group.find(params[:group_id])
    if group   
      response_object = {
                          status: "success",
                          group_transactions: group.transactions.where('created_at >=', 30.days.ago)
                        }
    else
      response_object = {
                          status: "failed",
                          errors: "group_id not found"
                        }
    end
    render json: response_object
  end
end
