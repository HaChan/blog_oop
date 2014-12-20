require "minitest/autorun"
require "ostruct"
require_relative "../../app/models/blog"

describe Blog do
  let(:entries){[]}
  subject{@blog = Blog.new}

  it "has no entries" do
    subject.entries.must_be_empty
  end

  describe "#new_post" do
    before do
      @new_post = OpenStruct.new
      subject.post_source = ->{@new_post}
    end

    it "return a new post" do
      subject.new_post.must_equal @new_post
    end

    it "set the post's blog reference to itself" do
      subject.new_post.blog.must_equal @blog
    end

    it "accept an attribute hash on behalf of the post maker" do
      post_source = MiniTest::Mock.new
      post_source.expect :call, @new_post, [{x: 42, y: "z"}]
      subject.post_source = post_source
      subject.new_post x: 42, y: "z"
      post_source.verify
    end
  end

  describe "#add_entry" do
    it "add entry to the blog" do
      entry = Object.new
      subject.add_entry entry
      subject.entries.must_include entry
    end
  end
end
