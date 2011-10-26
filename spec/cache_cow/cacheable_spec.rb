require 'spec_helper'

describe CacheCow::Cacheable do

  let(:cache_key) { "post:1" }

  describe ".fetch_cache" do

    it "returns nil if no block given and cache miss" do
      Post.fetch_cache(cache_key).should be_nil
    end

    it "writes through value from block on read" do
      Post.fetch_cache(cache_key) { "great post" }
      Post.fetch_cache(cache_key).should == "great post"
    end

    it "should be accessible from Rails.cache via class cache key" do
      Rails.cache.read(Post.cache_key(cache_key)).should be_nil
      Post.fetch_cache(cache_key) { "great post" }
      Rails.cache.read(Post.cache_key(cache_key)).should == "great post"
    end

  end

  describe ".read_cache" do
    it "should read value if cache hit" do
      Post.fetch_cache(cache_key) { "great post" }
      Post.read_cache(cache_key).should == "great post"
    end

    it "should return nil if cache miss" do
      Post.read_cache(cache_key).should be_nil
    end
  end

  describe ".write_cache" do
    it "should write value" do
      Post.write_cache(cache_key, "great post")
      Post.read_cache(cache_key).should == "great post"
    end
  end

  describe ".expire_cache" do
    it "should delete cached value" do
      Post.write_cache(cache_key, "great post")
      Post.expire_cache(cache_key)
      Post.read_cache(cache_key).should be_nil
    end
  end

  describe ".cached?" do
    it "should return true if cache hit" do
      Post.fetch_cache(cache_key) { "great post" }
      Post.cached?(cache_key).should be_true
    end

    it "should return false if cache miss" do
      Post.cached?(cache_key).should be_false
    end
  end

  describe ".cache_key" do

    it "should namespace cache_key to class:version:cache_key" do
      Post.cache_key(cache_key).should == "Post:1:post:1"
    end

    it "should namespace subclass to base class name" do
      BlogPost.cache_key(cache_key).should == "Post:1:post:1"
    end

  end

  describe "instance_methods" do
    let(:post) { stub_model(Post) }

    describe "#fetch_cache" do

      it "should write through value on read" do
        post.fetch_cache(cache_key).should be_nil
        post.fetch_cache(cache_key) { "great post" }
        post.fetch_cache(cache_key).should == "great post"
      end

      it "should use id as default cache_key if none given" do
        post.fetch_cache { "another great post" }
        Rails.cache.read(Post.cache_key(post.id)).should == "another great post"
      end

      it "should store value under key namespaced by class and id" do
        post.fetch_cache(cache_key) { "a third great post" }
        Rails.cache.read(Post.cache_key(post.cache_id(cache_key))).should == "a third great post"
      end

      describe "options" do
        it ":force => true forces cache miss" do
          post.fetch_cache { "another great post" }
          post.fetch_cache(cache_key, :force => true).should be_nil
        end
      end

      # spec for :compress
      # spec for :expires_in

    end

    describe "#cache_id" do
      it "should namespace key by its id" do
        post.cache_id("cache_key").should == "#{post.id}:cache_key"
      end
    end
  end

  # describe "get_multi" do
  #   it "should do a rails multiget with all the keys" do
  #     Rails.cache.should_receive(:read_multi).with(*[User.cache_key("a"), User.cache_key("b")])
  #     User.get_multi(["a", "b"]) {}
  #   end
  #
  #   it "should yield to a multiget object that passes along the appropriate options" do
  #     Rails.cache.should_receive(:read).with(User.cache_key("a"), :expires_in => '500').and_return("")
  #     User.get_multi(["a"]) do |multi|
  #       multi.fetch_cache("a", :expires_in => '500')
  #     end
  #   end
  # end

end
