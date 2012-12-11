require 'test_helper'
require 'minitest/autorun'

describe Labrador::Mysql do

  before do
    config = YAML.load(File.read(Rails.root.join("config/database.yml")))["adapter_test"]["mysql"]
    @mysql = Labrador::Mysql.new(
      host: config["host"],
      user: config["user"],
      password: config["password"],
      port: config["port"],
      database: config["database"],
      socket: config["socket"]
    )
    @mysql.session.query("DROP TABLE IF EXISTS users")
    @mysql.session.query("
      CREATE TABLE users(
        id INTEGER PRIMARY KEY UNIQUE,
        username VARCHAR(25),
        age INTEGER
      )
    ")
    1.upto(20) do |i|
      @mysql.session.query("
        INSERT INTO users (id, username, age) VALUES(#{i}, 'user#{i}', #{i + 10})
      ")
    end
  end

  describe '#collections' do
    it "should list collections/tables" do
      assert_equal ["users"], @mysql.collections
    end
  end

  describe '#primary_key_for' do
    it "should find primary key for collection/table" do
      assert_equal 'id', @mysql.primary_key_for(:users)
    end
  end

  describe '#find' do
    describe 'with no options' do
      it 'should find records' do
        results = @mysql.find(:users)
        assert results.any?
        assert_equal "user1", results.first["username"]
      end
    end

    describe 'with limit' do
      it 'should find records' do
        results = @mysql.find(:users, limit: 20)
        assert_equal 20, results.count
      end
    end

    describe 'with offset/skip' do
      it 'should find records' do
        results = @mysql.find(:users, skip: 10)
        assert_equal 'user11', results.first["username"]
      end
    end

    describe 'with order_by and direction' do
      it 'should find records' do
        results = @mysql.find(:users, order_by: 'username', direction: 'asc', limit: 1)
        assert_equal 'user1', results.first["username"]
        results = @mysql.find(:users, order_by: 'username', direction: 'desc', limit: 1)
        assert_equal 'user9', results.first["username"]
      end
    end

    describe '#fields_for' do
      it 'should find fields given results' do        
        assert_equal ["id", "username", "age"], @mysql.fields_for(@mysql.find(:users))
      end
    end
  end

  describe '#create' do
    before do
      @previousCount = @mysql.find(:users, limit: 1000).count
      @mysql.create(:users, id: 999, username: 'new_user', age: 100)
      @newUser = @mysql.find(:users, 
        limit: 1000, order_by: 'id', direction: 'desc', limit: 1).first
    end
    
    it 'insert a new record into the collection' do
      assert_equal @previousCount + 1, @mysql.find(:users, limit: 1000).count
    end

    it 'should create new record with given attributes' do
      assert_equal 'new_user', @newUser["username"]
      assert_equal 100, @newUser["age"].to_i
    end
  end

  describe '#update' do
    before do
      @previousCount = @mysql.find(:users, limit: 1000).count
      @userBeforeUpdate = @mysql.find(:users, 
        limit: 1000, order_by: 'id', directon: 'desc', limit: 1).first
      @mysql.update(:users, @userBeforeUpdate["id"], username: 'updated_name')
      @userAfterUpdate = @mysql.find(:users, 
        limit: 1000, order_by: 'id', directon: 'desc', limit: 1).first
    end
    
    it 'should maintain collection count after update' do
      assert_equal @previousCount , @mysql.find(:users, limit: 1000).count
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
      @previousCount = @mysql.find(:users, limit: 1000).count
      @firstUser = @mysql.find(:users, 
        limit: 1000, order_by: 'id', directon: 'asc', limit: 1).first
      @mysql.delete(:users, @firstUser["id"])
    end
    
    it 'should reduce collection record count by 1' do
      assert_equal @previousCount - 1, @mysql.find(:users, limit: 1000).count
    end

    it 'should delete record with given id' do
      newFirst = @mysql.find(:users, 
              limit: 1000, order_by: 'id', directon: 'asc', limit: 1).first
      assert @firstUser["id"] != newFirst["id"]
    end
  end

  describe '#connected?' do
    it 'should be connected' do
      assert @mysql.connected?
    end
  end

  describe '#close' do
    it 'should close connection' do
      @mysql.close
      assert !@mysql.connected?
    end
  end

  describe '#schema' do
    it 'should return schema for users table' do
      schema = @mysql.schema(:users)
      assert_equal 3, schema.length
      assert_equal "id", schema.first["Field"]
      assert_equal "username", schema.second["Field"]
      assert_equal "age", schema.third["Field"]
    end
  end 
end