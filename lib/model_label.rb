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

    def set_config(info)
      config = ModelLabel.model_label_config
      config[:label_model_info] = info

      info.values.each do |clazz|
        clazz.send(:include, ModelLabel::ConfigCourses)
      end

      ModelLabel.instance_variable_set(:@model_label_config, config)
    end

    def get_model_names
      label_model_info = ModelLabel.model_label_config[:label_model_info]
      label_model_info.keys
    end

    def get_models
      label_model_info = ModelLabel.model_label_config[:label_model_info]
      label_model_info.values
    end

    def get_model_by_name(name)
      label_model_info = ModelLabel.model_label_config[:label_model_info]
      label_model_info[name]
    end
  end
end

# 引用 rails engine
require 'model_label/config_courses'
require 'model_label/engine'
require 'model_label/rails_routes'
