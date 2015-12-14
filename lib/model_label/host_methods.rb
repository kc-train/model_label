module ModelLabel
  module HostMethods
    extend ActiveSupport::Concern
    included do
      field :label_info, :type => Hash

      scope :with_label, ->(name, value) {
        value = value.split if value.class == String
        value if value.class == Array
        where(:"label_info.#{name}".in => value)
      }
    end

    class_methods do
      def get_label_names
        # TODO ModelLabelConfigCourse 需要改进的部分
        temp = []
        label_all = ModelLabelConfigCourse.all.to_a
        label_all.each do |label|
          temp.push(label.label_info.keys)
        end
        return temp.flatten
      end
    end

    def set_label(name, value)
      info = self.label_info || {}
      old_values = info[name] || []
      old_values.push value
      info[name] = old_values
      self.label_info = info
    end

    def add_label(name, value)
      info = self.label_info || {}
      old_values = info[name] || []
      old_values.push value
      info[name] = old_values
      self.label_info = info
    end

    def remove_label(name, value)
      info = self.label_info || {}
      old_values = info[name] || []
      info[name] = old_values
      self.label_info = info.tap { |hs| hs.delete(name) }
    end

    def get_label_values(label_name)
      info = self.label_info || {}
      old_values = info[label_name] || []
      return old_values
    end
  end
end
