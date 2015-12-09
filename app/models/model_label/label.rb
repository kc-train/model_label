module ModelLabel
  class Label
    include Mongoid::Document
    include Mongoid::Timestamps

    field :model_name, type: String
    field :name , type: String
    field :values, type: Array

    validate :validation_model_pattern

    def model_name=(model_name)
      @model_name = model_name
    end

    def validation_model_pattern
      self.validation_exist_model
    end

    # 验证模型名是否在配置的范围内
    def validation_exist_model
      search = ModelLabel.get_models
      # new_s = s.gsub /"/, '|'
      p "~~~~~~~1"
      p @model_name
      p "~~~~~~~2"
      p search
      p "~~~~~~~3"
      p search.include?(@model_name)
      # if search_name.nil?
      #   errors.add(:model_name, "模型名不在范围内")
      # end
    end
  end
end