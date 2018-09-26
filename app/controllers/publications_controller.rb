class PublicationsController < ApplicationController
  autocomplete :publication, :root_url, label_method: :name
  
  def new
    @publication = Publication.new
  end
  
  def create
    @user = current_user
    @publication = Publication.find_or_create_by(root_url: publication_params[:root_url])
    @user.publications << @publication
    if @publication.new_record?
      @publication.save!
      # Code for a new pub
      @user.create_user_search(@publication.id, Time.now - 30.days)
      redirect_to user_path(@user), notice: 'Outlet was successfully created.'
    else
      # Code for an existing pub
      @user.create_user_search(@publication.id, Time.now - 30.days)
      redirect_to user_path(current_user), notice: 'Outlet was successfully added to your profile.'
    end
  end
  
  private
    # Using a private method to encapsulate the permissible parameters
    # is just a good pattern since you'll be able to reuse the same
    # permit list between create and update. Also, you can specialize
    # this method with per-user checking of permissible attributes.
    def publication_params
      params.require(:publication).permit(:name, :root_url)
    end

end
