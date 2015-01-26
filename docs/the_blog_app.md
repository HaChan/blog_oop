First, let's initialize a new blog app in rails.

    rails new blog_oop --skip-test-unit --skip-prototype

##Blog entries

A blog without entries isn't very useful. Let's add blog post to the app:

```ruby
class Blog
  attr_reader :entries

  def initialize
    @entries = []
  end
  # ...
end
```

**Making new entries**

Now the blog have it's entries, but nothing in it. The blog will need a method to make a new entries in it.

```ruby
@blog = Blog.new
@blog.new_post
```

The new_post method will return some kind of blog post object which is associated with the blog object. However, we want the blog object to be isolated, not dependant on any particular object so that it can make the test isolated and easier to change. So we'll make the new posts easily to swap out:

```ruby
class Blog
  # ...
  attr_writer :post_source
  # ...
  private
  def post_source
    @post_source ||= Post.public_method(:new)
  end
end
```

The `public_method` instantiates a call-able Method object. When the object's `call` method is invoked, it will be called as if we called the named method on the original object. Example:

```ruby
Post.public_method(:new).call # is the same with
Post.new
```

`public_method` will only generated public method on an object.

In this case, Post.public_method grabs a reference to a Method object representing the Post.new method which is not yet written. During normal operation, blog will use this method reference to generate post objects. But because post_source is an attr_writer attribute so it can be substituted with any call-able object when testing the class:

```ruby
require 'ostruct'
describe Blog do
  # ...
  describe "#new_post" do
    before do
      @new_post = OpenStruct.new
      @it.post_source = ->{ @new_post }
    end
    it "returns a new post" do
      @it.new_post.must_equal @new_post
    end
    it "sets the post's blog reference to itself" do
      @it.new_post.blog.must_equal(@it)
    end
  end
end
```

Here, post_source is substituted with a lambda which return an OpenStruct for the `post_source`.

The `new_post` will be straight forward:

```ruby
class Blog
  # ...
  def new_post
    post_source.call.tap do |p|
      p.blog = self
    end
  end
end
```

**Posts vs entries**

Here the terms may be confused. First, the blog has entries, then we are going to create posts. The multiple terms used here is deliberate. The darkside of having sensible framework conventions is that after a while, those conventions turns into assumptions. In this case, if `entries` are collection of `posts`, there's might be a chance we'd start mentally conflating it with the Post class. Anything in `blog.posts` is a Post instance.

This subtle assumptions can lead to big problems. For instance, if we assume `blog.new_post` is equivalent to `Post.new`, we might start to just skip the `Blog.new_post` and write `Post.new` or `Post.create` instead.

Now imagine that our Blog might have different kinds of posts - like photos, embedded videos,...- each represented by different classes such as PhotoPost, VideoPost... A call to Blog.new_post can use different types of Post class to create instance for the appropriate object. Because of the hard coded `Post.new`, now we have to change all the references of it in our codebase.

This kind of assumptions don't just lead to extra work; they can introduce security holes. Let's assume blog entries are posts, and as a result some of our controller actions look like this:

```ruby
def update
  @post = Post.find params[:id]
end
```

Then one day we decide to add the ability to host multiple blogs. The controllers are all updated to make sure that actions modifying a Blog can only be made by the user who own that blog.

This lead to a problem that if an user can guess someone else post's ID, he can modify its content easily because the calls to Post.find bypassed any scope constrains.

**Post class**

```ruby
class Post
  attr_accessor :blog, :title, :body

  def publish
    blog.add_entry self
  end
end
```

Look at this construction of Post might make you wonder that why `publish` instead of save.

One of the central elements of OO design is capturing the language of the domain in our models. In the blogging domain, it's unreasonable to say that _I saved a blog post_. The proper sentence here is _I publish a blog post_ or _I posted a blog entries_. By calling the method `publish`. the system can express the domain model more meaningful.

Consider how we might extend this program in the future. We might add scheduled posts, or add a draft state for posts. Our choice of the verb `publish` fits right into this extended workflow:

```ruby
post.save_draft
# followed by ...
post.schedule
# or...
post.publish
```

**Add entries to the blog**

As you might see that in publish method, we have the `blog.add_entry` operation. It means that when a post is publish, it is added to the blog entries.

```ruby
class Blog
  # ...
  def add_entry(entry)
    entries << entry
  end
  # ...
end
```

We will add a constructor method for Post class:

```ruby
class Post
  # ...
  def initialize(attrs={})
    attrs.each do |k,v| send("#{k}=",v) end
  end
  # ...
end
```

and we will make the blog `new_post` can take arguments:

```ruby
def new_post *args
  post_source.call(*args).tap do |p|
    p.blog = self
  end
end
```
