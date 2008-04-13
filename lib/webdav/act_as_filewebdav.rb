# Copyright (c) 2006 Stuart Eccles
# Released under the MIT License.  See the LICENSE file for more details.

# The act_as_filewebdav allows for simple filesystem exposure to be added to any ActionController
#
# class FileDavController < ActionController::Base
#    act_as_filewebdav :base_dir => 'public'
# end
# 
# The base_dir parameter can be a string for a directory or a symbol for a method which is run for every request allowing the base directory
# to be changed based on the request
#
# If the parameter :absolute = true the :base_dir setting will be treated as an absolute path, otherwise the it will be taken as a directory 
# underneath the RAILS ROOT


module Railsdav
  
  module ActAsFileWebDav
    
      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end 
  
      module ClassMethods
        def act_as_filewebdav(options = {})
          options[:base_dir] ||= '/'
          options[:absolute] ||= false
          class_inheritable_accessor :options
          self.options = options
    
          class_eval do 
            act_as_railsdav options
          end
          max_propfind_depth = 1
          include ActAsFileWebDav::InstanceMethods
        end

      end
       
    module InstanceMethods
       
        protected
   
       def mkcol_for_path(path)
         begin
           file_path = santized_path(path)
           #check for missing intermediate
           path.match(/(.*)\/.*$/)
           int_path = $1.nil? ? '/' : $1
           unless File.exists?(santized_path(int_path))
             raise WebDavErrors::TODO409Error
           else
             Dir.mkdir(file_path)
           end
          
           rescue Errno::ENOENT, Errno::EACCES
             #Forbidden
             raise WebDavErrors::ForbiddenError
           rescue Errno::ENOSPC
              #Insufficient Storage
             raise WebDavErrors::InsufficientStorageError
           rescue Errno::EEXIST
              #Conflict
             raise WebDavErrors::ConflictError
         end
       end 
       
       def write_content_to_path(path, content)
         begin
           file_path = santized_path(path)
           File.open(file_path, "wb") { |f| f.write(content) }
         rescue Errno::ENOENT
            #Conflict
            raise WebDavErrors::ConflictError
         rescue Errno::EPERM
            #Forbidden
            raise WebDavErrors::ForbiddenError
         end
       end
       
       def copy_to_path(resource, dest_path, depth)
          dest_file_path = santized_path(dest_path)
          
          #check for missing intermediate
          dest_path.match(/(.*)\/.*$/)
          int_path = $1.nil? ? '/' : $1
          unless File.exists?(santized_path(int_path))
            raise WebDavErrors::TODO409Error
          else
            #remove anything existing at the destination path
            remove_existing_dest_path(dest_file_path)
            resource.copy!(dest_file_path, depth)
          end
          
       end
       
       def move_to_path(resource, dest_path, depth)
          dest_file_path = santized_path(dest_path)
          
          #check for missing intermediate
          dest_path.match(/(.*)\/.*$/)
          int_path = $1.nil? ? '/' : $1
          unless File.exists?(santized_path(int_path))
            raise WebDavErrors::TODO409Error
          else
            #remove anything existing at the destination path
            remove_existing_dest_path(dest_file_path)
            resource.move!(dest_file_path, depth)
          end
          
       end
     
      def get_resource_for_path(path)
        begin  
          abs_file_path = santized_path(path)           
          return nil unless File.exists?(abs_file_path)
          FileWebDavResource.new(abs_file_path, href_for_path(path))
        rescue Errno::EPERM
          raise WebDavErrors::ForbiddenError
        end
      end
     
      def santized_path(file_path = '/')
         # Resolve absolute path.
         if (self.options[:base_dir].is_a?(Symbol))
           file_root = self.send(options[:base_dir])
         else
           file_root = options[:base_dir].clone
#           file_root = file_root[1..-1] if (file_root.first == "/")
           file_root = file_root[0..-2] if (file_root.last == "/")
        end
         
         unless (self.options[:absolute])
           file_root = File.join(RAILS_ROOT,file_root)
         end
         
         path = File.expand_path(File.join(file_root, file_path))
         
         # Deny paths that dont include the original path
         # TODO more work on the santized
         raise WebDavErrors::ForbiddenError unless path =~ /^#{File.expand_path(file_root)}/ 
         
         return path
     end
       
     def remove_existing_dest_path(dest_file_path)
       if (File.exists?(dest_file_path))
           begin
              FileUtils.rm_rf(dest_file_path)
            rescue Errno::ENOENT
               #Conflict
               raise WebDavErrors::ConflictError
            rescue Errno::EPERM
               #Forbidden
               raise WebDavErrors::ForbiddenError
            end
        end
     end
   end
     
  end
end
