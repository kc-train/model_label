module ModelLabel
  module HostMethods
    extend ActiveSupport::Concern
    included do
      field :label_info, :type => Hash

      scope :with_label, ->(name, value) {
        where(:"label_info.#{name}".in => [*value])
      }
    end

    class_methods do
      def get_label_names
        ModelLabel::Label.where(:model => self.to_s).map{|label|label.name}
      end
    end

    def set_label(name, value)
      info = self.label_info || {}
      info[name] = [*value]
      self.label_info = info
    end

    def add_label(name, value)
      info = self.label_info || {}
      old_values = info[name] || []
      old_values.push value if value.class == String
      if value.class == Array
        value.each do |val| 
          old_values.push val 
        end
      end
    end

    def remove_label(name, value)
      info = self.label_info || {}
      info[name].delete(value) if value.class == String
      if value.class == Array
        value.each do |val| 
          info[name].delete(val) 
        end 
      end
    end

    def get_label_values(label_name)
      info = self.label_info || {}
      old_values = info[label_name] || []
      return old_values
    end
  end
end
