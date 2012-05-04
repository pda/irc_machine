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

class String
  def irc_bold
    "#{0x02.chr}#{self}#{0x0F.chr}"
  end

  def irc_green
    "#{0x03.chr}3#{self}#{0x03.chr}"
  end

  def irc_red
    "#{0x03.chr}4#{self}#{0x03.chr}"
  end
end
