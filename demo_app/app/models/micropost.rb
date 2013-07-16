class Micropost < ActiveRecord::Base
  attr_accessible :content, :user_id

  belongs_to :user_id
  
  validates :conten, :length => { :maximum => 140 }
end
