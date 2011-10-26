class Post < ActiveRecord::Base
  acts_as_cached

  has_many :comments
  cached_id_list :comments
end
