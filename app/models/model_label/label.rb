module ModelLabel
  class Label
    include Mongoid::Document
    include Mongoid::Timestamps

    field :model, type: String
    field :name , type: String
    field :values, type: Array

    validates :model, :name, :values, presence: true

    validates :name, uniqueness: {scope: :model}

    validate :validation_model_pattern

    scope :with_model, -> (model) {
      where(model: model)
    }

    def validation_model_pattern
      self.validation_values_array_whether_empty
      self.validation_exist_model
      self.validation_values
    end

    # 验证当 values 是空数组时，不允许通过校验
    def validation_values_array_whether_empty
      if self.values.blank?
        errors.add(:values, "values 数组不能为空")
      end
    end

    # 验证模型名是否在配置的范围内
    def validation_exist_model
      if !ModelLabel.get_models.map{|mod| mod.to_s}.include?(self.model)
        errors.add(:model_name, "模型名不在范围内")
      end
    end

    # 验证 values 元素重复
    def validation_values
      return false if self.values == nil 
      if self.values.map{|val|val.to_s}.uniq.count != self.values.map{|val|val.to_s}.count
        errors.add(:values, "values 中元素重复")
      end
    end
  end
end