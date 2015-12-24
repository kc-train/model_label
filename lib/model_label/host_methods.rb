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
      label_set = self.class.where(:"label_info.#{name}".in => self.label_info[name]).first
      old_values = [*value].uniq
      searched_label = ModelLabel::Label.where(:model => self.class.to_s, name: name).first
      return false if old_values.map{|val| searched_label.values.include?(val)}.include?(false)
      label_set.label_info[name] = old_values
      label_set.save
      self.label_info = label_set.label_info
    end

    def add_label(name, value)
      info = self.label_info || {}
      old_values = info[name] || []
      label_add = self.class.where(:"label_info.#{name}".in => old_values).first
      old_values += [*value]
      searched_label = ModelLabel::Label.where(:model => self.class.to_s, name: name).first
      return false if [*value].uniq.map{|val| searched_label.values.include?(val)}.include?(false)
      label_add.label_info[name] = old_values.uniq
      label_add.save
      self.label_info = label_add.label_info
    end

    def remove_label(name, value)
      info = self.label_info || {}
      old_values = info[name] || []
      label_rm = self.class.where(:"label_info.#{name}".in => old_values).first
      return false if [*value].uniq.map{|val| info[name].include?(val)}.include?(false)
      label_rm.label_info[name] -= [*value]
      label_rm.save
      self.label_info = label_rm.label_info
    end

    def get_label_values(name)
      info = self.label_info || {}
      old_values = info[name] || []
      return old_values
    end
  end
end
