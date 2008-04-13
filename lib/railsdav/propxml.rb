# Copyright (c) 2006 Stuart Eccles
# Released under the MIT License.  See the LICENSE file for more details.
module Railsdav
  
  module PropXMLMethods
        
        def propfind_xml
        <<EOPROPFIND_XML 
         xml.D(:multistatus, {"xmlns:D" => "DAV:"}) do
            @resources.each do |resource|
               xml.D :response do
                   xml.D :href, resource.get_href
                   xml.D :propstat do
                      xml.D :prop do
          			         resource.get_properties.each do |property, value|
                          xml.D(property, value)
          			         end
          			         xml.D :resourcetype do
             				     xml.D :collection if resource.collection?
             			     end
                      end
          			       xml.D :status, resource.status
                   end
                end
            end
         end  
EOPROPFIND_XML
        end
        def proppatch_xml
          <<EOPROPPATCH_XML 
          xml.D(:multistatus, {"xmlns:D" => "DAV:"}) do
             xml.D :response do
                xml.D :href, URI.escape(@resource.get_href)
                for remove_property in @remove_properties
                    xml.D :propstat do
                      xml.D :prop do
                        xml.tag! remove_property.name.to_sym, remove_property.attributes
                      end
                      sym = ("remove_" + remove_property.name).to_sym
                      if @resource.respond_to?(sym)
                        xml.D(:status, @resource.__send__(sym))
                      else
                        xml.D :status, "HTTP/1.1 200 OK"
                      end
                    end
                end
                for set_property in @set_properties
                    xml.D :propstat do
                      xml.D :prop do
                        xml.D set_property.name.to_sym, set_property.attributes
                      end
                      sym = ("set_" + set_property.name).to_sym 
                      if @resource.respond_to?(sym)
                        method = @resource.method(sym)
                        if method.arity == 1 and set_property.children and set_property.children.size > 0
                            xml.D :status, method.call(set_property.children[0].to_s)
                        else
                            xml.D :status, method.call
                        end
                      else
                        xml.D :status, "HTTP/1.1 200 OK"
                      end
                    end
                end
       			    xml.D :responsedescription
             end
          end
EOPROPPATCH_XML
        end
  end
end