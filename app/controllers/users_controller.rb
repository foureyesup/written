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
  
  def remove_publication_from_user
     user = current_user
     publication = user.publications.find(params[:publication_id])
     if publication
        user.publications.delete(publication)
        redirect_to user_path(current_user), notice: 'publication.name has been removed from your outlets.'
     end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name)
  end

end
