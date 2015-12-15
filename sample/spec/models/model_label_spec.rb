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
        ModelLabel.get_models.each do |model_name|
          ml = ModelLabel::Label.create(:model => model_name.to_s,:name => "方向",:values => ["a","b"])
          expect(ml.valid?).to eq(true)
        end
      }

      it{
        ml = ModelLabel::Label.create(:model => "Lifeihahah",:name => "职务",:values => ["a","b"])
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

      @course = ModelLabelConfigCourse.create(
        :label_info => {"方向" => ["经济"]}
      )
    }

    describe "create" do
      it{
        expect(@course.valid?).to eq(true)
        expect(ModelLabelConfigCourse.where(:"label_info.方向".in => ["经济"]).to_a).to include(@course)
      }
    end

    describe "course.set_label(name, values)" do
      it{
        label = @course.set_label("方向","法律")
        expect(label["方向"]).to eq(["法律"])
      }
    end

    describe "course.add_label(name, value)" do
      it{
        label_info_before_length = @course.label_info.length
        label = @course.add_label("职务", "投资理财")
        label_info_after_length = @course.label_info.length
        expect(label_info_before_length + 1).to eq(label_info_after_length)
        expect(label).to eq(@course.label_info)
      }
    end

    describe "course.remove_label(name, value)" do
      it{
        label_info_before_length = @course.label_info.length
        label2 = @course.remove_label("方向","经济")
        label_info_after_length = @course.label_info.length
        expect(label_info_before_length - 1).to eq(label_info_after_length)
        expect(label2).to eq({})
      }
    end

    describe "course.get_label_values(label_name)" do
      it{
        values = @course.get_label_values("方向")
        expect(values).to eq(["经济"])
      }
    end

    describe "ModelLabelConfigCourse.with_label(name, value)" do
      it{
        temp = []
        temp.push(@course)
        @course1 = ModelLabelConfigCourse.create(
          :label_info => {"职务" => ["投资理财"]}
        )
        temp.push(@course1)
        search_label = ModelLabelConfigCourse.with_label("方向","经济").first
        expect(temp).to include(search_label)
      }
    end

    describe "ModelLabelConfigCourse.get_label_names" do
      it{
        search_names = ModelLabelConfigCourse.get_label_names

        expect(search_names).to include("方向")
      }
    end
  end
end
