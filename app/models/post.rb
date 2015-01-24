class Post < ActiveRecord::Base
  attr_accessor :blog

  validates :title, presence: true

  def publish clock=DateTime
    return unless valid?
    self.pubdate = clock.now
    blog.add_entry self
  end

  def picture?
    image_url.present?
  end
end
