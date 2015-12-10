module ModelLabel
  class Label
    include Mongoid::Document
    include Mongoid::Timestamps

    field :model, type: String
    field :name , type: String
    field :values, type: Array

    validates :model, :name, presence: true

    validates :model, uniqueness: {scope: :name}

    validate :validation_model_pattern

    def validation_model_pattern
      self.validation_exist_model
      self.validation_values
    end

    # 验证模型名是否在配置的范围内
    def validation_exist_model
      temp = []
      ModelLabel.get_models.each do |model_nm|
        temp.push(model_nm.to_s)
      end
      if !temp.include?(self.model)
        errors.add(:model_name, "模型名不在范围内")
      end
    end

    # 验证 values 元素重复和格式
    def validation_values
      self_values_before = self.values
      if self_values_before != nil
        self_values_after = self_values_before.uniq
        if (self_values_before.count != self_values_after.count) || self_values_before.map{|item| item.is_a?(String) }.include?(false)
          errors.add(:values, "values 中元素重复或格式不正确")
        end
      end
    end
  end
end