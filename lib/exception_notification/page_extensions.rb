module ExceptionNotification
  module PageExtensions
    
    def self.included(base)
      base.extend(ClassMethods)
    end
   
    def find_error_page(type)
      return nil unless page_class = ExceptionNotification::ERROR_TYPES[type]
      if self.class_name == page_class.name
        return self
      else
        children.each do |child|
          found = child.find_error_page(type)
          return found if found
        end
      end
      nil
    end
   
    module ClassMethods
      def find_error_page(type)
        root = find_by_parent_id(nil)
        if respond_to?(:current_site) && current_site
          root = current_site.homepage
        end
        raise Page::MissingRootPageError unless root
        root.find_error_page(type)
      end
    end
    
  end
end