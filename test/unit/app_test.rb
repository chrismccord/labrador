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

  describe 'self#find_all_from_sessions' do
    before do
      Labrador::Session.clear_all
      Labrador::Session.add Labrador::Session.new("name" => 'test1')
      Labrador::Session.add Labrador::Session.new("name" => 'test2')
      Labrador::Session.add Labrador::Session.new("name" => 'test3')
      @apps = Labrador::App.find_all_from_sessions(Labrador::Session.active)
    end

    it 'should find all apps in Session.active' do
      assert_equal Labrador::Session.active.count, @apps.count
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

  describe '#find_adapter_by_name' do
    it 'should be true with existing app by name' do
      app = Labrador::App.find_all_from_path("test/fixtures/apps").first
      assert app.find_adapter_by_name("mysql2")
    end

    it 'should be false with no existing app by name' do
      app = Labrador::App.find_all_from_path("test/fixtures/apps").first
      refute app.find_adapter_by_name("noexist")
    end
  end

  describe '#errors' do
    it 'should return an array of errors from all adapters' do
      app = Labrador::App.find_all_from_path("test/fixtures/apps").first
      assert app.errors.is_a? Array
    end
  end

  describe '#connect' do
    before do
      @app = Labrador::App.find_all_from_path("test/fixtures/apps").first
    end

    it 'should connect' do
      assert @app.connect
    end

    it 'should be connected' do
      @app.connect
      assert @app.connected?
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

