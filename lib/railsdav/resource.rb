# Copyright (c) 2006 Stuart Eccles
# Released under the MIT License.  See the LICENSE file for more details.
module WebDavResource
  
  def initialize(path)
    @path = path
  end
    
  def properties
    Array.new
  end
  
  def delete!
    
  end
  
  def move! (dest_path, depth)
    
  end
    
  def copy! (dest_path, depth)
    
  end
  
  def status
    gen_status(200, "OK").to_s
  end
  
  def collection?
    return false
  end
  
  def children
    return []
  end

  def get_displayname
    URI.escape(self.displayname).gsub(/\+/, '%20') unless self.displayname.nil?
  end

  def get_href
    self.href.gsub(/\+/, '%20') unless self.href.nil?
  end

  def get_properties
    hsh = {}
    self.properties.each do|meth|
      if self.respond_to?('get_'+meth.to_s)
        hsh[meth] = self.send(('get_'+meth.to_s).to_sym)
      else
        hsh[meth] = self.send(meth)
      end
    end
    hsh
  end

  protected
   def gen_element(elem, text = nil, attrib = {})
     e = REXML::Element.new elem
     text and e.text = text
     attrib.each {|k, v| e.attributes[k] = v }
     e
   end
   
   def gen_status(status_code, reason_phrase)
       "HTTP/1.1 #{status_code} #{reason_phrase}"
   end
end