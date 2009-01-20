module ActionController
  class AbstractRequest
    HTTP_METHODS = %w(get head put post delete options lock unlock propfind proppatch mkcol delete put copy move)
    HTTP_METHOD_LOOKUP = HTTP_METHODS.inject({}) { |h, m| h[m] = h[m.upcase] = m.to_sym; h }
  end
end