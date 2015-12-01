module ModelLabel
  class << self
    def model_label_config
      self.instance_variable_get(:@model_label_config) || {}
    end

    def set_mount_prefix(mount_prefix)
      config = ModelLabel.model_label_config
      config[:mount_prefix] = mount_prefix
      ModelLabel.instance_variable_set(:@model_label_config, config)
    end

    def get_mount_prefix
      model_label_config[:mount_prefix]
    end
  end
end

# 引用 rails engine
require 'model_label/engine'
require 'model_label/rails_routes'
