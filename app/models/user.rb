class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_and_belongs_to_many :publications
  has_many :stories
  has_many :searches
  has_many :results
  
  def create_user_search(publication_id, start_date)
    publication = Publication.find(publication_id)
    Search.create!(
      query: %Q[site:#{publication.root_url} (author:"#{self.name}" OR text:"#{self.name}")],
      user_id: self.id,
      publication_id: publication.id,
      start_date: start_date,
      search_name: self.name,
      search_url: publication.root_url
    )
  end
  
end
