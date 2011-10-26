require 'spec_helper'

describe CacheCow::CachedIdList do

  let(:post) { Factory(:post) }
  let(:comment) { Factory(:comment) }

  describe ".cached_id_list" do

    describe "comments" do
      before(:each) do
        post.comments << comment
        post.save!
      end

      it "should return ids by association" do
        post.cached_comment_ids.should == post.comment_ids
      end

      it "should write data to rails cache" do
        post.cached_comment_ids # set cache
        Rails.cache.read(post.cache_key("cached_comment_ids")).should == post.comment_ids
      end

      it "should return [] if no comments" do
        Factory(:post).cached_comment_ids.should == []
      end
    end


    describe "blog_comments" do
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

  describe "#expire_cached_id_list" do
    it "should expire list of cached ids from given association name" do
      post.comments << comment
      post.cached_comment_ids # set cache

      post.expire_cached_id_list(:comments)

      Rails.cache.read(post.cache_key("cached_comment_ids")).should be_nil
    end
  end
end
