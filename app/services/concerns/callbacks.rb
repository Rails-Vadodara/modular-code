module Callbacks
  def self.extended(base)
    base.send(:include, InstanceMethods)
  end

  def overridden_methods
    @overridden_methods ||= []
  end

  def callbacks
    @callbacks ||= Hash.new { |hash, key| hash[key] = [] }
  end

  def method_added(method_name)
    return if should_override?(method_name)

    overridden_methods << method_name
    original_method_name = "original_#{method_name}"
    alias_method(original_method_name, method_name)

    define_method(method_name) do |*args|
      run_callbacks_for(method_name)
      send(original_method_name, *args)
    end
  end

  def should_override?(method_name)
    overridden_methods.include?(method_name) || method_name =~ /original_/
  end

  def before_run(method_name, callback)
    method_name.each { |method| callbacks[method] << callback }
  end

  module InstanceMethods
    def run_callbacks_for(method_name)
      self.class.callbacks[method_name].to_a.each do |callback|
        send(callback)
      end
    end
  end
end
