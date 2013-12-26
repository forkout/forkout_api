class ServicesController < ApplicationController
  def group_expences_report
    unless params[:group_id]
      render json: {status: "failed", message: "missing paramater : group_id"}
      return
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
                        group_id: params[:group_id],
                        total_expences: total_expences,
                        expences_per_head: expences_per_head,
                        details: data

                      }

    render json: response_object
  end
end

