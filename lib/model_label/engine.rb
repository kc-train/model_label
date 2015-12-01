module ModelLabel
  class Engine < ::Rails::Engine
    isolate_namespace ModelLabel
    config.to_prepare do
      ApplicationController.helper ::ApplicationHelper

      Dir.glob(Rails.root + "app/decorators/model_label/**/*_decorator.rb").each do |c|
        require_dependency(c)
      end
    end
  end
end
