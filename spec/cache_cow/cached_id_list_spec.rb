require 'spec_helper'

describe CacheCow::CachedIdList do

  describe "cached_id_list" do
    it "should return ids by association" do
      comment_1 = Factory(:comment)
      comment_2 = Factory(:comment)
      post      = Factory(:post)
      post.comments << comment_1
      post.comments << comment_2
      post.save!
      post.cached_comment_ids.should == post.comment_ids
    end

    it "should return ids by subclass association" do
      comment_1 = Factory(:blog_comment)
      comment_2 = Factory(:blog_comment)
      post      = Factory(:blog_post)
      post.comments << comment_1
      post.comments << comment_2
      post.save!
      post.cached_comment_ids.should == post.comment_ids
    end
  end
end
