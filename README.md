# CacheCow

CacheCow allows ActiveRecord models to `acts_as_cached``


## Install

In your Gemfile

    gem "cache_cow"

Or via command line

    gem install cache_cow


## Overview

CacheCow provides an api for caching results of methods and associations on ActiveRecord models.

To use in a model, declare `acts_as_cached`

``` ruby
class Post
  acts_as_cached
end
```

Instances of a cache_cow model can read, write, fetch, and expire their own cache keys. Cache keys
are namespaced and versioned by convention as <class_name>:<version>:<id>:<cache_suffix>. An instances
id is the cache suffix be default.

``` ruby
# Post.cache_cow_version = 1

post = Post.find(123)

post.fetch_cache { "great post" }     # fetches from cache key 'Post:1:123', store 'great post' on cache miss

post.write_cache("foo", "bar")        # writes 'bar to cache key 'Post:1:123:foo'

post.read_cache("foo")                # returns 'bar' from cache key 'Post:1:123:foo'
````

