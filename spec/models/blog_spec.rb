require "ostruct"
require_relative "../spec_helper_lite"
require_relative "../../app/models/blog"

describe Blog do
  let(:entries){[]}
  subject{@blog = Blog.new ->{entries}}

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
      entry = stub!
      mock(entry).save
      subject.add_entry entry
    end
  end

  describe "entries" do
    def stub_entry_with_date date
      OpenStruct.new pubdate: DateTime.parse(date)
    end
  end
end
