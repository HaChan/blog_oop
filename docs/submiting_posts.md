The blog should be able to submit new entries.

So what we need is a route, a controller and a form:

```ruby
# config/routes.rb
# ...
resources :posts

################

# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def new
    @post = @blog.new_post
  end

  def create
    @post = @blog.new_post params[:post]
    @post.publish
    redirect_to root_path, notice: "Post added!"
  end
end

################

<!-- app/views/posts/new.html.erb -->
<h1>New Post</h1>
<%= form_for @post do |f| %>
  <%= f.text_field :title %>
  <%= f.text_area :body %>
  <%= f.submit %>
<% end %>
```

Look at the PostsController that we need the `@blog` object to make the code work. And because the blog controller need it too, so we need to instantiate it in ApplicationController:

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :init_blog

  private
  def init_blog
    @blog = Blog.new
  end
end
```

Because rails has some conventions with the model in order to construct form for object, and our Post class doesn't know about this. To make the Post object aware of these conventions, let's use ActiveModel modules to do that:

```ruby
class Post
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  # ...

  def persisted?
    false
  end

  # ...
end
```

But, there is just one litle problem here: a new blog object is created with every request to the app server. What we need is a single blog object across requests.

So we just need to store a blog instance to an app using an initializer.

```ruby
# config/initializers/blog.rb
THE_BLOG = Blog.new

######################

# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :init_blog

  private
  def init_blog
    @blog = THE_BLOG
  end
end
```

Let's take a look at the create action in PostsController:

```ruby
def create
  @post = @blog.new_post(params[:post])
  @post.publish
  redirect_to root_path, notice: "Post added!"
end
```

Although it's an action in PostsController, it does not have Post class, or more concise post instance dose not created directly by Post class.

Object Oriented programs tend to evolve into a roughly tree-shaped struture. This mimic how we tend to think of the world around us as well as the world inside our programs. A blog website has a blog, a blog has categories, a category has entries, an entry has tags and so on.

The problem with this view of OOP is that most complex system don't have a single nature hierarchy to them. With the blog example, we could also have a blog has authors, authors have entries, and entries might have categories associated with them.

The point here is we natually break our system into hierarchies, also called _trees of objects_. In a tree of objects, each object mediate access to its "leaf" or "branch" object. So, a blog object can be accessed by the site object, a category from the blog object, and articles from the category object.

This pattern has some attractive properties. Having "parent" object mediate access to "child" objects provide a natural "seam" in our design. At the seam, we can do a number of things:

- Controll access based on authorization information. E.g edit post of a particular blog.

- Pre-load "child" objects with a reference of their parent. The `new_post` method of Blog does this, it creates a new post and add a reference of itself to the post.

- Save a reference to the child object in the parent. ActiveRecord's `autosave` does this.

- Decide the actual class of the child object to be instantiated, based on the params or state of the parent object.

Every time an explicit reference of a class is used to create or access an object, rather than using the parent object to do it, all the advantages above is rejected.

Consider these lines:

```ruby
@post = Post.new(params[:post])
@post = Post.create(params[:post])
@post = Post.find(params[:id])
```

These objects has no family, no ties to its community so it is hard for these object to collaborate in the system.

It might make the test more painful:

```ruby
post = stub(:post)
Post.stub(:new).and_return(:post)
```

Having to stub `new`, or override a method on every instance of an object, is a bad approach to testing

Because the Post class now have included ActiveModel module, it can not be tested isolatedly. Rails have a mechanism to autoload constants that have not included in the app, but our isolated minitest have not include any dependency in order to make the test fast.

The easiest way to make the test pass is to include ActiveModel some where in the test setup. But it is not necessary since there are plenty of way to make the test work with out including ActiveModel directly.

First we can make a fake ActiveModel module like this:

```ruby
module ActiveModel
  module Naming; end
  module Conversion; end
end
```

Then we can include it in our minitest file. This approach is problematic. Consider that some time in the future you might want to include full-stack test. As a result it will load the full Rails enviroment. Depending on the load order that may cause this definition of ActiveModel's module is loaded and it will not load the real ActiveModel's module.

So what we need is a way that conditionally create empty or stub modules if:

  - they are not already defined;

  - they are not auto-loadable

Here is the method does just that:

```ruby
def stub_module(full_name)
  full_name.to_s.split(/::/).inject(Object) do |context, name|
    begin
      context.const_get name
    rescue NameError
      context.const_set name, Module.new
    end
  end
end
```

`const_get` will find the constant passed to it in the whole file and all the included files. If `const_get` method fails to turn up a constant (in this function is Module), it will create a new one and set it in a constant through `const_set` method.
