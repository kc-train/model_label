module ModelLabel
  module HostMethods
    extend ActiveSupport::Concern
    included do
      field :label_info, :type => Hash

      scope :with_label, ->(name, value) {
        where(:"label_info.#{name}".in => value)
      }

    end

    def set_label(name, value)
      info = self.label_info || {}
      old_values = info[name] || []
      old_values.push value
      info[name] = old_values
      self.label_info = info
    end
  end
end
