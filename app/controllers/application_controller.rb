class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper :exhibits

  before_filter :init_blog
  private
  def init_blog
    @blog = THE_BLOG
  end
end
