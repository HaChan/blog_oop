class Post
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :blog, :title, :body, :pubdate

  validates :title, presence: true

  def initialize attrs={}
    attrs.each {|k, v| send "#{k}=", v}
  end

  def publish clock=DateTime
    return unless valid?
    self.pubdate = clock.now
    blog.add_entry self
  end

  def persisted?
    false
  end
end
