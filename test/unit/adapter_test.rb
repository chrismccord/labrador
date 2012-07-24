require 'test_helper'
require 'minitest/autorun'

describe Labrador::Adapter do

  before do
    @app = Labrador::App.find_all_from_path("test/fixtures/apps").first
    @adapter = @app.adapters.first
  end

  describe '#database_yml_config' do
    it 'should find database.yml configuration' do
      assert @adapter.database_yml_config
      assert_equal "mysql2", @adapter.database_yml_config["adapter"]
    end
  end

  describe '#mongoid_yml_config' do
    it 'should find mongoid.yml configuration' do
      app = Labrador::App.find_all_from_path("test/fixtures/apps").third
      assert @adapter.mongoid_yml_config
      assert_equal "mongodb", @adapter.mongoid_yml_config["adapter"]
    end
  end

  describe '#configuration' do
    it 'should lazy load configuration from configuration path' do
      assert @adapter.configuration
    end
  end

  describe '#valid?' do
    it 'should be valid' do
      assert @adapter.valid?
    end
  end

  describe '#connect' do
    # TODO
  end
end

