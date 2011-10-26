class AddStiToPostsAndComments < ActiveRecord::Migration
  def change
    add_column :posts, :type, :string
    add_column :comments, :type, :string
  end
end