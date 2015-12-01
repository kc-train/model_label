module ModelLabel
  class Routing
    # ModelLabel::Routing.mount "/model_label", :as => 'model_label'
    def self.mount(prefix, options)
      ModelLabel.set_mount_prefix prefix

      Rails.application.routes.draw do
        mount ModelLabel::Engine => prefix, :as => options[:as]
      end
    end
  end
end
