module ModelLabel
  class Label
    include Mongoid::Document
    include Mongoid::Timestamps

    field :model_name, type: String
    field :name , type: String
    field :values, type: Array

    def model=(model)
      @model = model
    end

    validate :validation_model_pattern

    def validation_model_pattern
      self.set_model_name
      self.validation_exist_model
      self.validation_unique
      self.validation_values_unique
    end

    def set_model_name
      self.model_name = @model
    end

    # 验证模型名是否在配置的范围内
    def validation_exist_model
      temp = []
      ModelLabel.get_models.each do |model|
        temp.push(model.to_s)
      end
      if !temp.include?(@model)
        errors.add(:model_name, "模型名不在范围内")
      end
    end

    def validation_unique
      search = ModelLabel::Label.where(model_name: @model, name: self.name, values: self.values).to_a
      if search.count > 1
        errors.add(:model, "name 与 values 联合查找不唯一")
      end
    end

    def validation_values_unique
      self_values_before = self.values
      # p self_values_before.length
      # if !self.values.uniq?
      #   errors.add(:values, "values中的元素不能重复")
      # end
    end
  end
end