require "minitest/autorun"
require_relative "../spec_helper_lite"
require_relative "../../app/helpers/exhibits_helper"
require_relative "../../app/exhibits/exhibit"
require_relative "../../app/exhibits/text_post_exhibit"
require_relative "../../app/exhibits/picture_post_exhibit"

stub_class "PicturePostExhibit"
stub_class "TextPostExhibit"
stub_class "LinkExhibit"
stub_class "Post"

describe ExhibitsHelper do
  subject{Object.new}
  let(:context){stub!}

  before{subject.extend ExhibitsHelper}

  it "decorates picture posts with a PicturePostExhibit" do
    post = Post.new
    stub(post).picture?{true}
    assert_equal subject.exhibit(post, context).is_a?(PicturePostExhibit), true
  end

  it "decorates text posts with a TextPostExhibit" do
    post = Post.new
    stub(post).picture?{false}
    assert_equal subject.exhibit(post, context).is_a?(TextPostExhibit), true
  end

  it "leaves objects it doesn't know about alone" do
    model = Object.new
    subject.exhibit(model, context).must_be_same_as model
  end
end
