# Copyright (c) 2006 Stuart Eccles
# Released under the MIT License.  See the LICENSE file for more details.

# The FileWebDavResource represents a WebDavResource representing a filesystem files and directories
# It exposes a set of properties that are central to representing to a WebDAV client as a file system
# These are displayname, creationdate, getlastmodified, getetag, getcontenttype and getcontentlength
# The FileWebDavResource allows for setting of the displayname and last modified dates.

require 'mime/types'

class FileWebDavResource

   include WebDavResource
   attr_accessor :file, :href
   
   WEBDAV_PROPERTIES = [:displayname, :creationdate, :getlastmodified, :getetag, :getcontenttype, :getcontentlength]
   
   #First argument should be a File with then an absolute href to the file. The href is returned with the propfind
   def initialize(*args)
      @file = args.first
      @st = File.lstat(@file)
      
      if args.last.is_a?(String)
         @href = args.last
         @href = @href + '/' if collection?
      end
   end
   
   def collection?
     unless @file.nil?
       File.directory?(@file) 
     end
   end
   
   def delete!
     begin
       FileUtils.rm_rf(@file)
     rescue Errno::EPERM
        raise WebDavErrors::ForbiddenError
     end
   end
   
   def move! (dest_path, depth)
     begin
       File.rename(@file, dest_path)
      rescue Errno::ENOENT
        #Conflict
        raise WebDavErrors::ConflictError
      rescue Errno::EPERM
        #Forbidden
        raise WebDavErrors::ForbiddenError
      end
   end

   def copy! (dest_path, depth)
     begin
       FileUtils.cp_r(@file, dest_path, {:preserve => true})
     rescue Errno::ENOENT
         #Conflict
         raise WebDavErrors::ConflictError
      rescue Errno::EPERM
         #Forbidden
         raise WebDavErrors::ForbiddenError
      end
   end
   
   def children
    return [] unless collection?
    resources = []
    Dir.entries(@file).each do |entry|
      entry == ".." || entry == "." and next
      resources << FileWebDavResource.new(File.join(@file,entry), File.join(@href,entry))
    end
    return resources
   end
   
   def properties
     WEBDAV_PROPERTIES
   end 

   def displayname 
      File.basename(@file) unless @file.nil?
   end
   
   def set_displayname(value)
      begin
        File.rename(@file, value)
        gen_status(200, "OK").to_s
       rescue Errno::EACCES, ArgumentError
          gen_status(409, "Conflict").to_s
       rescue
          gen_status(500, "Internal Server Error").to_s
       end 
   end
   
   def creationdate
      @st.ctime.xmlschema unless @file.nil?
   end
   
   def getlastmodified
      @st.mtime.httpdate unless @file.nil?
   end
   
   def set_getlastmodified(value)
     begin
      File.utime(Time.now, Time.httpdate(value), @file)
      gen_status(200, "OK").to_s
     rescue Errno::EACCES, ArgumentError
        gen_status(409, "Conflict").to_s
     rescue
        gen_status(500, "Internal Server Error").to_s
     end
   end
   
   def getetag
      sprintf('%x-%x-%x', @st.ino, @st.size, @st.mtime.to_i) unless @file.nil?
   end
      
   def getcontenttype
      mimetype = MIME::Types.type_for(displayname).first.to_s
      mimetype = "application/octet-stream" if mimetype.blank?
      File.file?(@file) ? mimetype : "httpd/unix-directory"  unless @file.nil?
   end
      
   def getcontentlength 
      File.file?(@file) ? @st.size : nil unless @file.nil?
   end
   
   def data
     File.new(@file)
   end

end