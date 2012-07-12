require 'test_helper'
require 'minitest/autorun'

describe Labrador::App do

  before do
  end

  describe 'self#find_all_from_path' do
    before do
      @apps = Labrador::App.find_all_from_path("test/fixtures/apps")
    end

    it 'should find all apps in directory' do
      assert_equal 3, @apps.count
    end

    it 'should find all active record/database.yml apps' do
      assert @apps.collect(&:name).include?("database_yml_app1")
      assert @apps.collect(&:name).include?("database_yml_app2")
    end

    it 'should find all mongoid apps' do
      assert @apps.collect(&:name).include?("mongoid_app1")
    end
  end

  describe 'self#is_supported_app?' do
    it 'should be true for directories that are rails apps' do
      assert Labrador::App.is_supported_app?("test/fixtures/apps/database_yml_app1")
      assert Labrador::App.is_supported_app?("test/fixtures/apps/database_yml_app2")
      assert Labrador::App.is_supported_app?("test/fixtures/apps/mongoid_app1")
    end

    it 'should not be true for directories that are not rails apps' do
      assert !Labrador::App.is_supported_app?("test/fixtures/not_valid_app")
    end
  end

  describe '#adapter_names' do
    it 'should collect adapter names' do
      app = Labrador::App.find_all_from_path("test/fixtures/apps").first
      assert_equal ["mysql2"], app.adapter_names
    end
  end

  describe '#to_s' do
    it 'should convert to string' do
      app = Labrador::App.find_all_from_path("test/fixtures/apps").first
      assert app.to_s
    end
  end

  describe '#as_json' do
    it 'should convert as json' do
      app = Labrador::App.find_all_from_path("test/fixtures/apps").first
      assert app.as_json
      assert app.to_json
    end
  end
end

