require 'rails_helper'


RSpec.describe ModelLabel::Label, type: :model do
  before :context do
    class ModelLabelConfigCourse
      include Mongoid::Document
      include Mongoid::Timestamps
    end

    class ModelLabelConfigQuestion
      include Mongoid::Document
      include Mongoid::Timestamps
    end

    ModelLabel.set_config({
      "课程"   => ModelLabelConfigCourse,
      "测试题" => ModelLabelConfigQuestion
    })
  end

  describe "field validates" do
    describe "model_name 取值必须在 config 中配置的模型名范围内" do
      it{
        name = "方向"
        ModelLabel.get_models.each do |model_name|
          ml = ModelLabel::Label.create(:model => model_name.to_s,:name => name)
          expect(ml.valid?).to eq(true)
        end
      }

      it{
        ml = ModelLabel::Label.create(:model => "Lifeihahah",:name => "职务")
        expect(ml.valid?).to eq(false)
      }
    end

    describe "model_name name 两个字段取值联合唯一" do
      it{
        name = "方向"
        model_name = "ModelLabelConfigCourse"
        expect{
          ml = ModelLabel::Label.create(:model => model_name, :name => name, :values => ["a","b"])
          expect(ml.valid?).to eq(true)
        }.to change{
          ModelLabel::Label.count
        }.by(1)

        name2 = "职务"
        expect{
          ml = ModelLabel::Label.create(:model => model_name, :name => name2, :values => ["a","b"])
          expect(ml.valid?).to eq(true)
        }.to change{
          ModelLabel::Label.count
        }.by(1)

        name = "方向"
        expect{
          ml = ModelLabel::Label.create(:model => model_name, :name => name, :values => ["a","b"])
          expect(ml.valid?).to eq(false)
          expect(ml.errors.messages[:model]).not_to be_nil
        }.to change{
          ModelLabel::Label.count
        }.by(0)
      }
    end

    describe "values 取值的数组中，不能有重复的数组元素" do
      it{
        model_name = "ModelLabelConfigCourse"
        expect{
          ml = ModelLabel::Label.create(:model => model_name, :name => "方向", :values => ["a","a"])
          expect(ml.valid?).to eq(false)
          expect(ml.errors.messages[:values]).not_to be_nil
        }.to change{
          ModelLabel::Label.count
        }.by(0)

        expect{
          ml = ModelLabel::Label.create(:model => model_name, :name => "方向", :values => ["a", :a])
          expect(ml.valid?).to eq(false)
          expect(ml.errors.messages[:values]).not_to be_nil
        }.to change{
          ModelLabel::Label.count
        }.by(0)

        expect{
          ml = ModelLabel::Label.create(:model => model_name, :name => "方向", :values => ["1", 1])
          expect(ml.valid?).to eq(false)
          expect(ml.errors.messages[:values]).not_to be_nil
        }.to change{
          ModelLabel::Label.count
        }.by(0)
      }
    end
  end

  describe "ModelLabelConfigCourse 设置 label" do
    before{
      name1 = "方向"
      ModelLabel::Label.create(:model => "ModelLabelConfigCourse", :name => name1, :values => ["法律","经济"])

      name2 = "类型"
      ModelLabel::Label.create(:model => "ModelLabelConfigCourse", :name => name2, :values => ["视频","PPT"])
    }

    describe "create" do
      it{
        expect{
          course = ModelLabelConfigCourse.create(
            :label_info => {"方向" => ["经济"]}
          )
          expect(ModelLabelConfigCourse.where(:"label_info.方向".in => ["经济"]).to_a).to include(course)
        }.to change{
          ModelLabelConfigCourse.count
        }.by(1)

      }
    end

    describe "course.set_label(name, values)" do
      
    end

    describe "course.add_label(name, value)" do
      # TODO
    end

    describe "course.remove_label(name, value)" do
      # TODO
    end
  end

  describe "ModelLabelConfigCourse.with_label(name, value)" do
    # TODO
  end

  describe "ModelLabelConfigCourse.get_label_names" do
    # TODO
  end

  describe "course.get_label_values(label_name)" do
    # TODO
  end
end
