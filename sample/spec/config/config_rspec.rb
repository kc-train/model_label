require 'rails_helper'


RSpec.describe ModelLabel, type: :config do
  before :context do
    class ModelLabelConfig::Course
      include Mongoid::Document
      include Mongoid::Timestamps
    end

    class ModelLabelConfigQuestion
      include Mongoid::Document
      include Mongoid::Timestamps
    end

    ModelLabel.set_config {
      "课程"   => ModelLabelConfig::Course,
      "测试题" => ModelLabelConfigQuestion
    }
  end

  it{
    expect(ModelLabel.get_model_names).to include(["课程", "测试题"])
  }

  it{
    expect(ModelLabel.get_models).to include([ModelLabelConfig::Course, ModelLabelConfigQuestion])
  }

  it{
    expect(ModelLabel.get_model_by_name("课程")).to eq(ModelLabelConfig::Course)
  }

  it{
    expect(ModelLabel.get_model_by_name("测试题")).to eq(ModelLabelConfigQuestion)
  }
end
