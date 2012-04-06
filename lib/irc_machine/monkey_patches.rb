class Hash
  def symbolize_keys
    inject({}) do |h, (k,v)|
      h[k.to_sym] = case v
                    when Hash
                      v.symbolize_keys
                    else
                      v
                    end
      h
    end
  end
end