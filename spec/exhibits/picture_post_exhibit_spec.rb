require_relative "../spec_helper_lite"
require_relative "../../app/exhibits/picture_post_exhibit"

describe PicturePostExhibit do
  let(post) do
    OpenStruct.new title: "Title", body: "Body", pubdate: "Pubdate"
  end

  let(context){stub!}

  subject{PicturePostExhibit.new post, context}

  it "delegates method calls to the post" do
    subject.title.must_equal "Title"
    subject.body.must_equal "Body"
    subject.pubdate.must_equal "Pubdate"
  end

  it "render itself with the appropriate partial" do
    mock(context)
      .render(partial: "post/picture_body", locals: {post: subject}){
        "The_HTML"
      }
      subject.render_body.must_equal "The_HTML"
  end
end
