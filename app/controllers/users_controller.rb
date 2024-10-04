class UsersController < ApplicationController
  before_action :correct_user, only: [:show]
  skip_before_action :login_required, only: [:new, :create]

  def new
    @user = User.new
  end

  

  def create

    @user = User.new(user_params)

    # ユーザのログインが完了したら悲観的ロックを適用
    if @user.save
      # ログインする
      log_in(@user)

      ActiveRecord::Base.transaction do


        @orders = Order.find_by(id: params[:order_id])

        # @ordersがnilかどうか確認
        if @orders.nil?
          flash[:error] = "Order not found"
          render :new

          raise ActiveRecord::Rollback  # トランザクションをロールバック
            # 商品を購入不可に更新する
            @orders.update!(available: false)
          

          # 成功時のリダイレクト
          redirect_to new_order_path
        else
          # ユーザーの登録に失敗した場合の処理
          render :new
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
