class Post
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :blog, :title, :body

  def initialize attrs={}
    attrs.each {|k, v| send "#{k}=", v}
  end

  def publish
    blog.add_entry self
  end

  def persisted?
    false
  end
end
