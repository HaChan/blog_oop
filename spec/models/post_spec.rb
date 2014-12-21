require "minitest/autorun"
require "active_model"
require_relative "../spec_helper_lite"
require_relative "../../app/models/post"

describe Post do
  subject{@post = Post.new}

  it "starts with blank attributes" do
    subject.title.must_be_nil
    subject.body.must_be_nil
  end

  it "supports reading and writing a title" do
    subject.title = "foo"
    subject.title.must_equal "foo"
  end

  it "supports reading and writing a post body" do
    subject.body = "foo"
    subject.body.must_equal "foo"
  end

  it "supports reading and writing a blog reference" do
    blog = Object.new
    subject.blog = blog
    subject.blog.must_equal blog
  end

  it "supports setting attributes in the initializer" do
    it = Post.new title: "mytitle", body: "mybody"
    it.title.must_equal "mytitle"
    it.body.must_equal "mybody"
  end

  it "is not valid with a blank title" do
    [nil, "", ""].each do |bad_title|
      subject.title = bad_title
      refute subject.valid?
    end
  end

  it "is valid with a non-blank title" do
    subject.title = "title"
    assert subject.valid?
  end

  describe "#publish" do
    before do
      @blog = MiniTest::Mock.new
      subject.title = "title"
      subject.blog = @blog
    end

    after do
      @blog.verify
    end

    it "adds the post to the blog" do
      @blog.expect :add_entry, nil, [subject]
      subject.publish
    end

    describe "given an invalid post" do
      before{subject.title = nil}

      it "wont add the post to the blog" do
        dont_allow(@blog).add_entry
        subject.publish
      end

      it "return false" do
        refute subject.publish
      end
    end
  end

  describe "#pubdate" do
    describe "before publishing" do
      it "is blank" do
        subject.pubdate.must_be_nil
      end
    end

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
  end
end
