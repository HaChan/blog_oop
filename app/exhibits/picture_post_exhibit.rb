class PicturePostExhibit < Exhibit
  def render_body
    @context.render partial: "/posts/picture_body", locals: {post: self}
  end

  class << self
    def applicable_to? object
      object.is_a?(Post) && object.picture?
    end
  end
end
