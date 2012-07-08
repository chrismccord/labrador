require 'test_helper'
require 'minitest/autorun'

describe Labrador::MongoDB do

  before do
    config = YAML.load(File.read(Rails.root.join("config/database.yml")))["adapter_test"]["mongodb"]
    @mongo = Labrador::MongoDB.new(
      host: config["host"],
      user: config["user"],
      password: config["password"],
      port: config["port"],
      database: config["database"]
    )
    @mongo.session[:users].drop
    1.upto(20) do |i|
      @mongo.session[:users].insert(
        username: "user#{i}", 
        age: i + 10
      )
    end
  end

  describe '#collections' do
    it "should list collections/tables" do
      assert_equal ["system.indexes", "users"], @mongo.collections
    end
  end

  describe '#find' do
    describe 'with no options' do
      it 'should find records' do
        results = @mongo.find(:users)
        assert results.any?
      end
    end

    describe 'with limit' do
      it 'should find records' do
        results = @mongo.find(:users, limit: 20)
        assert_equal 20, results.count
      end
    end

    describe 'with offset/skip' do
      it 'should find records' do
        results = @mongo.find(:users, skip: 10)
        assert_equal 'user11', results.first["username"]
      end
    end

    describe 'with order_by and direction' do
      it 'should find records' do
        results = @mongo.find(:users, order_by: 'username', direction: 'asc', limit: 1)
        assert_equal 'user1', results.first["username"]
        results = @mongo.find(:users, order_by: 'username', direction: 'desc', limit: 1)
        assert_equal 'user9', results.first["username"]
      end
    end

    describe '#fields_for' do
      it 'should find fields given results' do        
        assert_equal ["_id", "age", "username"], @mongo.fields_for(@mongo.find(:users))
      end
    end
  end
end