require 'railsdav'

ActionController::Base.send(:include, Railsdav)
ActionController::Base.send(:include, Railsdav::ActAsFileWebDav)