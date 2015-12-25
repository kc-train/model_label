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
          expect(ml.errors.messages[:name]).not_to be_nil
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

    describe "name,model和values不能为空 " do 
      it{
        expect{
          ml = ModelLabel::Label.create(name: "方向", values: ["a","b"])
          expect(ml.valid?).to eq(false)
          expect(ml.errors.messages[:model]).not_to be_nil
        }.to change{
          ModelLabel::Label.count
        }.by(0)

        expect{
          ml = ModelLabel::Label.create(model: "ModelLabelConfigCourse", values: ["a","b"])
          expect(ml.valid?).to eq(false)
          expect(ml.errors.messages[:name]).not_to be_nil
        }.to change{
          ModelLabel::Label.count
        }.by(0)

        expect{
          ml = ModelLabel::Label.create(model: "ModelLabelConfigCourse", name: "方向")
          expect(ml.valid?).to eq(false)
          expect(ml.errors.messages[:values]).not_to be_nil
        }.to change{
          ModelLabel::Label.count
        }.by(0)

        expect{
          ml = ModelLabel::Label.create(model: "ModelLabelConfigCourse", name: "方向", values: [])
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
      ModelLabel::Label.create(:model => "ModelLabelConfigCourse", :name => name1, :values => ["法律","经济","政治","投资理财"])

      name2 = "类型"
      ModelLabel::Label.create(:model => "ModelLabelConfigCourse", :name => name2, :values => ["视频","PPT"])

      name3 = "职务"
      ModelLabel::Label.create(:model => "ModelLabelConfigCourse", :name => name3, :values => ["柜员","管理员"])

      @label_info_data = [
        {"方向" => ["法律","经济","政治"],"类型" => ["视频","PPT"]},
        {"职务" => ["柜员","管理员"]},
        {"类型" => ["视频","PPT"]},
        {"方向" => ["法律","经济"]}
      ]
      @model_label_data = []
      @label_info_data.each do |info|
        course = ModelLabelConfigCourse.create(
          :label_info => info
        )
        @model_label_data.push(course)
      end
    }

    describe "create" do
      it{
        @model_label_data.each do |info|
          info_key = info.label_info.keys
          info_key.each do |key|
            expect(info.valid?).to eq(true)
            expect(ModelLabelConfigCourse.where(:"label_info.#{key}".in => info.label_info[key]).to_a).to include(info)
          end
        end
      }
    end

    describe "course.set_label(name, values)" do
      it{
        name = "方向"
        @model_label_data.each do |info|
          if info.label_info.keys.include?(name)
            info.set_label(name,["投资理财"])
            info = ModelLabelConfigCourse.find info.id
            expect(info.label_info[name]).to eq(["投资理财"])
          end
        end
      }

      it{
        name = "方向"
        @model_label_data.each do |info|
          if info.label_info.keys.include?(name)
            course_setl = info.set_label(name,["hello"])
            info = ModelLabelConfigCourse.find info.id
            expect(info.label_info[name]).not_to include("hello")
          end
        end
      }
    end

    describe "course.add_label(name, value)" do
      it{
        name = "方向"
        @model_label_data.each do |info|
          if info.label_info.keys.include?(name)
            info.add_label(name, ["投资理财"])
            info = ModelLabelConfigCourse.find info.id
            expect(info.label_info[name]).to include("投资理财")
          end
        end
      }

      it{
        name = "方向"
        @model_label_data.each do |info|
          if info.label_info.keys.include?(name)
            course_addl = info.add_label(name, ["军史"])
            info = ModelLabelConfigCourse.find info.id
            expect(info.label_info[name]).not_to include("军史")
          end
        end
      }
    end

    describe "course.remove_label(name, value)" do
      it{
        name = "方向"
        @model_label_data.each do |info|
          if info.label_info.keys.include?(name)
            info.remove_label("方向","经济")
            info = ModelLabelConfigCourse.find info.id
            expect(info.label_info["方向"]).not_to include("经济")
          end
        end
      }

      it{
        name = "方向"
        @model_label_data.each do |info|
          if info.label_info.keys.include?(name)
            info.remove_label(name,["经济","法律","政治"])
            info = ModelLabelConfigCourse.find info.id
            expect(info.label_info[name]).not_to include("经济","法律","政治")
          end
        end
      }
    end

    describe "course.get_label_values(label_name)" do
      it{
        name = "方向"
        @model_label_data.each do |info|
          if info.label_info.keys.include?(name)
            values = info.get_label_values(name)
            expect(values).to include("经济")
          end
        end
      }
    end

    describe "ModelLabelConfigCourse.with_label(name, value)" do
      it{
        name = "方向"
        @model_label_data.each do |info|
          if info.label_info.keys.include?(name)
            search_label = ModelLabelConfigCourse.with_label(name,"经济").to_a
            expect(search_label).to include(info)
          end
        end
      }
    end

    describe "ModelLabelConfigCourse.get_label_names" do
      it{
        search_names = ModelLabelConfigCourse.get_label_names
        expect(search_names).to include("方向")
      }
    end
  end

  describe "ModelLabel::Label.with_model(model)" do 
    before{
      @temp = []
      name1 = "职务"
      @model_label_one = ModelLabel::Label.create(:model => "ModelLabelConfigCourse", :name => name1, :values => ["柜员","管理员"])
      @temp.push(@model_label_one)

      name2 = "方向"
      @model_label_two = ModelLabel::Label.create(:model => ModelLabelConfigCourse, :name => name2, :values => ["法律","经济","政治","投资理财"])
      @temp.push(@model_label_two)

      name3 = "类型"
      @model_label_three = ModelLabel::Label.create(:model => ModelLabelConfigQuestion, :name => name3, :values => ["Word","Excel","PPT","视频"])
      @temp.push(@model_label_three)

      name4 = "方向"
      @model_label_four = ModelLabel::Label.create(:model => "ModelLabelConfigQuestion", :name => name4, :values => ["法律","经济","政治","投资理财"])
      @temp.push(@model_label_four)
    }

    describe "传入的值分别为字符串和类" do
      it{
        @temp.each do |mdlb|
          expect(mdlb.valid?).to eq(true)
          expect(ModelLabel::Label.where(model: mdlb.model, name: mdlb.name).first).to eq(mdlb)
        end
      }

      it{
        model_in_label = ModelLabel::Label.with_model("ModelLabelConfigCourse").to_a
        expect(model_in_label).to include(@model_label_one)
      }

      it{
        model_in_label = ModelLabel::Label.with_model(ModelLabelConfigCourse).to_a
        expect(model_in_label).to include(@model_label_two)
      }

      it{
        model_in_label = ModelLabel::Label.with_model(ModelLabelConfigQuestion).to_a
        expect(model_in_label).to include(@model_label_three)
      }

      it{
        model_in_label = ModelLabel::Label.with_model("ModelLabelConfigQuestion").to_a
        expect(model_in_label).to include(@model_label_four)
      }
    end
  end
end
