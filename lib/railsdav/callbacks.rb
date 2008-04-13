
#This module WebDavCallbacks adds callbacks before and after webdav methods
#Overidding classes can add methods before and after every webdav method by overriding
#before_webdav_{methpod} and after_webdav_{method}

module Railsdav
  
  module WebDavCallbacks
      
      CALLBACKS = %w(
        before_webdav_get after_webdav_get 
        before_webdav_put after_webdav_put 
        before_webdav_copy after_webdav_copy 
        before_webdav_move after_webdav_move
        before_webdav_propfind after_webdav_propfind 
        before_webdav_proppatch after_webdav_proppatch 
        before_webdav_mkcol after_webdav_mkcol
      )
      
      def self.included(base) #:nodoc:
        base.extend(ClassMethods)
        base.class_eval do

          [:webdav_get, :webdav_put, :webdav_copy, :webdav_move, :webdav_propfind, :webdav_proppatch, :webdav_mkcol].each do |method|
            alias_method_chain method, :callbacks
          end
        end
        
      end
      
    module ClassMethods
    end
      
    def before_webdav_get() end
    def after_webdav_get() end
        
    def webdav_get_with_callbacks
        before_webdav_get()
        result = webdav_get_without_callbacks()
        after_webdav_get()
        return result
    end
    
    def before_webdav_put() end
    def after_webdav_put() end
    
    def webdav_put_with_callbacks
        before_webdav_put()
        result = webdav_put_without_callbacks()
        after_webdav_put()
        return result
    end
    
    def before_webdav_copy() end
    def after_webdav_copy() end
    
    def webdav_copy_with_callbacks
         before_webdav_copy()
         result = webdav_copy_without_callbacks()
         after_webdav_copy()
         return result
    end 
    
    def before_webdav_move() end
    def after_webdav_move() end
    
    def webdav_move_with_callbacks
        before_webdav_move()
        result = webdav_move_without_callbacks()
        after_webdav_move()
        return result
    end
    
    def before_webdav_propfind() end
    def after_webdav_propfind() end
    
    def webdav_propfind_with_callbacks
        before_webdav_propfind()
        result = webdav_propfind_without_callbacks()
        after_webdav_propfind()
        return result
    end
    
    def before_webdav_proppatch() end
    def after_webdav_proppatch() end
    
    def webdav_proppatch_with_callbacks
         before_webdav_proppatch()
         result = webdav_proppatch_without_callbacks()
         after_webdav_proppatch()
         return result
    end
    
    def before_webdav_mkcol() end
    def after_webdav_mkcol() end
    
    def webdav_mkcol_with_callbacks
         before_webdav_mkcol()
         result = webdav_mkcol_without_callbacks()
         after_webdav_mkcol()
         return result
    end
  end

end