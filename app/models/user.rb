class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable
         
  has_and_belongs_to_many :publications
  has_many :stories
  
  def create_user_search(publication_id, start_date)
    publication = Publication.find(publication_id)
    Search.create!(
      query: "site:" + publication.root_url + " " + self.name,
      user_id: self.id,
      publication_id: publication.id,
      start_date: start_date
    )
  end
  
end
