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


  describe '#create' do
    before do
      @previousCount = @mongo.find(:users, limit: 1000).count
      @mongo.create(:users, username: 'new_user', age: 100)
      @newUser = @mongo.find(:users, 
        limit: 1000, order_by: '_id', direction: 'desc', limit: 1).first
    end
    
    it 'insert a new record into the collection' do
      assert_equal @previousCount + 1, @mongo.find(:users, limit: 1000).count
    end

    it 'should create new record with given attributes' do
      assert_equal 'new_user', @newUser["username"]
      assert_equal 100, @newUser["age"]
    end
  end

  describe '#update' do
    before do
      @previousCount = @mongo.find(:users, limit: 1000).count
      @userBeforeUpdate = @mongo.find(:users, 
        limit: 1000, order_by: '_id', directon: 'desc', limit: 1).first
      @mongo.update(:users, @userBeforeUpdate["_id"], username: 'updated_name')
      @userAfterUpdate = @mongo.find(:users, 
        limit: 1000, order_by: '_id', directon: 'desc', limit: 1).first
    end
    
    it 'should maintain collection count after update' do
      assert_equal @previousCount, @mongo.find(:users, limit: 1000).count
    end

    it 'should update record with given attributes' do
      assert_equal 'updated_name', @userAfterUpdate["username"]
    end

    it 'should not alter existing attributes not included for update' do
      assert_equal @userBeforeUpdate["age"], @userAfterUpdate["age"]
    end
  end

  describe '#delete' do
    before do
      @previousCount = @mongo.find(:users, limit: 1000).count
      @firstUser = @mongo.find(:users, 
        limit: 1000, order_by: '_id', directon: 'asc', limit: 1).first
      @mongo.delete(:users, @firstUser["_id"])
    end
    
    it 'should reduce collection record count by 1' do
      assert_equal @previousCount - 1, @mongo.find(:users, limit: 1000).count
    end

    it 'should delete record with given id' do
      newFirst = @mongo.find(:users, 
        limit: 1000, order_by: '_id', directon: 'asc', limit: 1).first
      assert @firstUser["_id"] != newFirst["_id"]
    end
  end

  describe '#connected?' do
    it 'should be connected' do
      assert @mongo.connected?
    end
  end

  describe '#close' do
    it 'should close connection' do
      @mongo.close
      assert !@mongo.connected?
    end
  end

  describe '#schema' do
    it 'should return empty array' do
      assert_equal [], @mongo.schema(:users)
    end
  end
end