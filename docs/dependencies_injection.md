**Adding time stamp**

Two feature that are pretty much require for a blog are:

  - time-stamped posts

  - listing post in reverse-chronological order

First we need a way (funtion) to display the time-stamp:

    entry.pubdate

An entry's time-stamp should be blank first and then be filled in once the entry is published. Let's spec that out:

```ruby
describe "#pubdate" do
  describe "before publishing" do
    it "is blank" do
      @it.pubdate.must_be_nil
    end
  end

  describe "after publishing" do
    before do
      @it.blog = stub!
      @it.publish
    end

    it "is a datetime" do
      @it.pubdate.class.must_equal(DateTime)
    end
  end
end
```

Because of the insufficient facilities of the Minitest's built-in mocking, it's needed to be supplemented with [rr](https://github.com/rr/rr), a succint but powerfull test double library. Although in the index file of `rr` note that it is no longer maintained since 27/12/2014 and recommended to use `rspec-mock` instead. It still sufficent in our small experiment app.

Here is the setup for `rr`:

```ruby
# spec/spec_helper_lite.rb
require 'rr'

class MiniTest::Unit::TestCase
  include RR::Adapters::MiniTest
end

# Gemfile
group :development, :test do
  # ...
  gem 'rr'
end
```

Implementing `pubdate` is just a new attributr accessor:

```ruby
class Post
  attr_accessor :blog, :title, :body, :pubdate
  #...
```

Time-stamp should return time:

```ruby
subject{@post = Post.new}

#...

describe "after publishing" do
  before do
    @clock = stub!
    @now = DateTime.parse "2014-12-21T12:22"
    stub(@clock).now(){@now}
    subject.blog = stub!
    subject.title = "title"
    subject.publish @clock
  end

  it "is a datetime" do
    subject.pubdate.class.must_equal DateTime
  end

  it "is the current time" do
    subject.pubdate.must_equal @now
  end
end
```

In this test, we creating a stubbed blog instance, a clock `@clock` stub, a fixed `@now` time for the clock to respond with `now` method call. The `@clock` is passed into `Post#publish` method and assert that a post instance uses the `@now` time to set to its `pubdate` attributes.

But this might lead to a problem that the app will always have to pass a clock object into `Post#publish`. Fortunately, Ruby's method can have a default value for parameter:

```ruby
class Post
  #...
  def publish(clock=DateTime)
    self.pubdate = clock.now
    blog.add_entry(self)
  end
  #...
end
```

The `clock` parameter of `publish` method have it's default value DateTime class. That way by default, `publish` method will use the DateTime class to set the pubdate current time through its `now` method.

By making possible to pass the clock in, we have made our class and test isolated from any external dependencies. The behaviour of `publish` method can be easily tested with a little bit of stubbing object and method.

**Dependency Injection (DI)**

Looking back to our app now that we have used DI twice. First, we used _setter injection_ to strategize how blog objects create new entries:

```ruby
class Blog
  attr_writer :post_source

  #...

  def post_source
    @post_source ||= Post.public_method(:new)
  end
end
```

Then we used _parameter injection_ to pass a clock object into `Post#publish` method:

```ruby
def publish(clock=DateTime)
  self.pubdate = clock.now
  blog.add_entry(self)
end
```

DI is just about passing an object's collaborators in from the outside the definition of the object's class. With the power of metaprogramming, Ruby makes it very easy to inject dependencies.

Beside of making the test isolatedly, DI can make the app felxible, changeable without modifing the current class. Connsider this example: we want to add the ability to post-date or pre-date some posts. Currently, `Post` sets its `pubdate` at publish time, and because the clock is injectable, we can implement custom publish dates without making any changes at all to Post class:

```ruby
fixed_clock = OpenStruct.new(now: DateTime.parse(params[:pubdate]))
@post.publish(fixed_clock)

#########################
#########################

class DelayClock
  def now
    DateTime.now + 24.hours
  end
end
# ...
@post.publish(DelayClock.new)
```

According to the Single Responsibility Principle (SRP), a class should have one and one reason only to change. A corollary of this princible is that when a new requirement requires changes to more than one class or module, at least one of them probably has too many responsibilities.

So if the clock isn't injectable, implementing post-date and pre-date would require the code changed in two places: once in controller, and once in the Post model. But with our design, the code only need to change in one place (mostly controller).

Now you might wonder why we inject a callable `@post_source` instead of a `@post_class` variable which defaults to Post like the `clock` variable.

It because it makes the test setup easier. If a _post class_ mock is injected, we have to do two things:

  - Stub `new` method on the Post class, which would override globally and may interfere with any test code which also call `Post.new`

  - Create a `@post_class` stub and a `@post` stub and stub the `@post_class` to return `@post`

Bu contrast, all we need to do is stub the callable version is:

```ruby
blog.post_source = ->{ new_post }
```

One thing with injecting the `@post_class` is that the Blog can use `@post_class` to call other method on it and making Blog not isolated from dependencies.

Instead, `Blog#new_post` depends on "some callable which will return a post when called". It make the Blog and Post class not binding their interface, and they have minimum connection.

And finally, `post_source` is a factory as in the Factory pattern.

**Sorting and limiting posts**

Implement this feature is pretty simple in plain Ruby:

```ruby
# app/models/blog.rb
# ...
# add new entry to list
def add_entry(entry)
  @entries << entry
end

def entries
  @entries.sort_by{|e| e.pubdate}.reverse.take(10)
end
# ...
```

And here is the spec test:

```ruby
describe "entries" do
  def stub_entry_with_date date
    OpenStruct.new pubdate: DateTime.parse(date)
  end

  it "is sorted in reverse-chronological order" do
    oldest = stub_entry_with_date "2014-12-21"
    newest = stub_entry_with_date "2014-12-23"
    middle = stub_entry_with_date "2014-12-22"
    subject.add_entry oldest
    subject.add_entry newest
    subject.add_entry middle
    subject.entries.must_equal [newest, middle, oldest]
  end

  it "is limites to 10 items" do
    10.times do |i|
      subject.add_entry stub_entry_with_date "2014-12-#{i+1}"
    end
    oldest = stub_entry_with_date "2014-11-30"
    subject.add_entry oldest
    subject.entries.length.must_equal 10
    subject.entries.wont_include oldest
  end
end
```
