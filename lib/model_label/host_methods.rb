module ModelLabel
  module HostMethods
    extend ActiveSupport::Concern
    included do
      field :label_info, :type => Hash, :default => {}

      validate :check_value_whether_in_label

      scope :with_label, ->(name, value) {
        where(:"label_info.#{name}".in => [*value])
      }
    end

    def check_value_whether_in_label
      info_key = self.label_info.try(:keys) || []
      info_key.each do |name|
        searched_label = ModelLabel::Label.where(:model => self.class.to_s, name: name).first
        if searched_label == nil
          errors.add(:name, "label_info的key 不在规定的范围内")
          return true
        end

        if self.label_info[name].map{|val| searched_label.values.include?(val)}.include?(false)
            errors.add(:value, "label_info的value 不在规定的范围内")
        end
      end
    end

    class_methods do
      def get_label_names
        ModelLabel::Label.where(:model => self.to_s).map{|label|label.name}
      end
    end

    def set_label(name, value)
      afferent_value = [*value].uniq
      self.label_info[name] = afferent_value
      self.save
    end

    def add_label(name, value)
      info = self.label_info || {}
      old_values = info[name] || []
      old_values += [*value]
      self.label_info[name] = old_values.uniq
      self.save
    end

    def remove_label(name, value)
      self.label_info[name] -= [*value].uniq
      self.save
    end

    def get_label_values(name)
      info = self.label_info || {}
      old_values = info[name] || []
      return old_values
    end
  end
end
