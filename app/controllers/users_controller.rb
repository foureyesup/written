class UsersController < ApplicationController
  #before_action :authenticate_user!

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end
  
  def update
    @user = current_user
    redirect_to @user.tap { |user|
      user.update!(user_params)
    }
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name)
  end

end
