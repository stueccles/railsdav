require 'active_support'

module WebDavErrors
    
    class BaseError < Exception
      
    end
    
    class LockedError < WebDavErrors::BaseError
      @@http_status = 423
      cattr_accessor :http_status
    end
  
    class InsufficientStorageError < WebDavErrors::BaseError
      @@http_status = 507
      cattr_accessor :http_status
    end
    
    class ConflictError < WebDavErrors::BaseError
      @@http_status = 405      
      cattr_accessor :http_status
    end
    
    class ForbiddenError < WebDavErrors::BaseError
      @@http_status = 403
      cattr_accessor :http_status
    end
    
    class BadGatewayError < WebDavErrors::BaseError
      @@http_status = 502
      cattr_accessor :http_status
    end
    
    class PreconditionFailsError < WebDavErrors::BaseError
      @@http_status = 412
      cattr_accessor :http_status
    end
    
    class NotFoundError < WebDavErrors::BaseError
      @@http_status = 404
      cattr_accessor :http_status
    end
    
    class UnSupportedTypeError < WebDavErrors::BaseError
      @@http_status = 415
      cattr_accessor :http_status
    end
    
    class UnknownWebDavMethodError < WebDavErrors::BaseError
      @@http_status = 405
      cattr_accessor :http_status
    end
    
    class BadRequestBodyError < WebDavErrors::BaseError
      @@http_status = 400
      cattr_accessor :http_status
    end
    
    class TODO409Error < WebDavErrors::BaseError
      @@http_status = 409
      cattr_accessor :http_status
    end
end