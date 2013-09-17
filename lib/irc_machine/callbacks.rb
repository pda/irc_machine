require 'uuid'

module IrcMachine::Plugin::Callbacks

  def has_callbacks(path, opts={}, &block)
    name = opts[:method_name] || raise("Method name must be specified.")
    define_method name do |&blk|
      blk ||= (block || raise("No block given"))
      callback_base = opts[:callback_base] || settings["callback_base"]

      callback = {}
      callback[:url] = URI(callback_base).tap do |uri|
        callback[:path] = "#{path}/#{UUID.new.generate}"
        uri.path = callback[:path]
      end
      route(:post, callback[:path], blk)
      callback
    end
  end

end
