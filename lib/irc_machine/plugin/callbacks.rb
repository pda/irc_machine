
module Callbacks

  def has_callbacks(path, opts={}, &block)
    name = opts[:method_name] || raise("Method name must be specified.")
    define_method name do
      callback_base = opts[:callback_base] || settings["callback_base"]

      callback = {}
      callback[:url] = URI(callback_base).tap do |uri|
        callback[:path] = "#{path}/#{@uuid.generate}"
        uri.path = callback[:path]
      end
      route(:post, callback[:path], block)
      callback
    end
 	end

end
