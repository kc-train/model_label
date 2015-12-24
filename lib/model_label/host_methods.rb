module ModelLabel
  module HostMethods
    extend ActiveSupport::Concern
    included do
      field :label_info, :type => Hash

      scope :with_label, ->(name, value) {
        where(:"label_info.#{name}".in => [*value])
      }
    end

    def check_value_whether_in_label(name,value)
      searched_label = ModelLabel::Label.where(:model => self.class.to_s, name: name).first
      if value.map{|val| searched_label.values.include?(val)}.include?(false)
        errors.add(:value, "您所设置的value 不在规定的范围内")
      end
    end

    class_methods do
      def get_label_names
        ModelLabel::Label.where(:model => self.to_s).map{|label|label.name}
      end
    end

    def set_label(name, value)
      old_values = [*value].uniq
      feedback_infm = check_value_whether_in_label(name,old_values)
      if feedback_infm == nil
        self.label_info[name] = old_values
        self.save
      else
        feedback_infm 
      end
    end

    def add_label(name, value)
      info = self.label_info || {}
      old_values = info[name] || []
      old_values += [*value]
      feedback_infm = check_value_whether_in_label(name,[*value].uniq)
      if feedback_infm == nil
        self.label_info[name] = old_values.uniq
        self.save
      else
        feedback_infm
      end
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
