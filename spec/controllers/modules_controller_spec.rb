require 'spec_helper'

describe ModulesController do
  describe "load_module_tree" do
    before :each do
      ModuleResult.expects(:find).with(42).returns(FactoryGirl.build(:module_result))
      request.env["HTTP_ACCEPT"] = 'application/javascript' # FIXME: there should be a better way to force JS

      post :load_module_tree, {id: 42}
    end

    it { should respond_with(:success) }
    it { should render_template(:load_module_tree) }
  end

  describe "metric_history" do
    let (:module_id){ 1 }
    let (:metric_name ){ FactoryGirl.build(:loc).name }
    let (:date ){ DateTime.parse("2011-10-20T18:26:43.151+00:00") }
    let (:metric_result){ FactoryGirl.build(:metric_result) }
    let! (:module_result){ FactoryGirl.build(:module_result) }

    before :each do
      ModuleResult.expects(:find).at_least_once.with(module_result.id).returns(module_result)
      module_result.expects(:metric_history).with(metric_name).returns({date => metric_result.value})
      subject.expire_fragment("#{module_result.id}_#{metric_name}")

      request.env["HTTP_ACCEPT"] = 'application/javascript' # FIXME: there should be a better way to force JS
      get :metric_history, id: module_result.id, metric_name: metric_name, module_id: module_id
    end

    it { should respond_with(:success) }
    it { should render_template(:metric_history) }
  end 
end