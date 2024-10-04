class UsersController < ApplicationController
  before_action :correct_user, only: [:show]
  skip_before_action :login_required, only: [:new, :create]

  def new
    @user = User.new
  end

  

  def create
    # フォームの内容からuserインスタンス作成
    @user = User.new(user_params)

    # ユーザのログインが完了したら悲観的ロックを適用
    # userインスタンスの保存
    if @user.save
      # 自動ログインする
      log_in(@user)

      # トランザクションの開始
      ActiveRecord::Base.transaction do


        @orders = Order.find_by(id: params[:order_id])

        # @ordersがnilかどうか確認し、注文に失敗していたら以降が実行される
        if @orders.nil?
          # 注文が無ければ以下を表示
          flash[:error] = "Order not found"

          #新規ユーザ
          render :new

          # 今までのトランザクションをロールバック
          raise ActiveRecord::Rollback 
          
        # 注文に成功した場合
        else
            # 商品を購入不可に更新する
          @orders.update!(available: false)
          redirect_to new_order_path
        end
      end
    end
  end





  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to current_user unless current_user?(@user)
  end
end
