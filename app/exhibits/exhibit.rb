require "delegate"
class Exhibit < SimpleDelegator
  def initialize model, context
    @context = context
    super model
  end

  def to_model
    __getobj__
  end

  def class
    __getobj__.class
  end

  class << self
    # this function can be replaced by inherited hook
    def exhibits
      [TextPostExhibit, PicturePostExhibit]
    end

    def exhibit object, context
      exhibits.inject(object) do |object, exhibit|
        exhibit.exhibit_if_applicable object, context
      end
    end

    def exhibit_if_applicable object, context
      if applicable_to? object
        new object, context
      else
        object
      end
    end

    def applicable_to? object
      false
    end
  end
end
