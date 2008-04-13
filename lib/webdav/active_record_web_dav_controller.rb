# Copyright (c) 2006 Stuart Eccles
# Released under the MIT License.  See the LICENSE file for more details.

class ActiveRecordWebDavController < ActionController::Base
  
  act_as_railsdav
  
  protected

  def mkcol_for_path(path)
      #Forbidden
      raise WebDavErrors::ForbiddenError
  end 
  
  def write_content_to_path(path, content)
    obj = YAML::load( content )
    obj.save if obj
  end

  def get_resource_for_path(path)
     return ActiveRecordResource.new(href_for_path(nil)) if path.blank? or path.eql?("/") 
     model, id = path.split('/')
     unless model.nil?
       
       kls = Inflector.classify( model )
       clazz = Module::const_get( kls )
       clazz.find :first rescue raise WebDavErrors::NotFoundError
     end
     
     if id.nil?
       return ActiveRecordResource.new(clazz, href_for_path(path))
     else
       if /(\w+)\.yaml$/ =~ id
         return ActiveRecordResource.new(clazz.find($1.to_i), href_for_path(path))
       else
         raise WebDavErrors::NotFoundError
       end
     end
     
  end

end

