require 'test_helper'
require 'minitest/autorun'

describe Labrador::Sqlite do

  before do
    @sqlite = Labrador::Sqlite.new(database: Rails.root.join("test/fixtures/sqlite.sqlite3").to_s)
    @sqlite.session.execute("DROP TABLE IF EXISTS users")
    @sqlite.session.execute("
      CREATE TABLE users(
        id INTEGER PRIMARY KEY UNIQUE,
        username VARCHAR(25),
        age INTEGER
      )
    ")
    1.upto(20) do |i|
      @sqlite.session.execute("
        INSERT INTO users (id, username, age) VALUES(#{i}, 'user#{i}', #{i + 10})
      ")
    end
  end

  describe '#collections' do
    it "should list collections/tables" do
      assert_equal ["users"], @sqlite.collections
    end
  end

  describe '#primary_key_for' do
    it "should find primary key for collection/table" do
      assert_equal 'id', @sqlite.primary_key_for(:users)
    end
  end

  describe '#find' do
    describe 'with no options' do
      it 'should find records' do
        results = @sqlite.find(:users)
        assert results.any?
        assert_equal "user1", results.first["username"]
      end
    end

    describe 'with limit' do
      it 'should find records' do
        results = @sqlite.find(:users, limit: 20)
        assert_equal 20, results.count
      end
    end

    describe 'with offset/skip' do
      it 'should find records' do
        results = @sqlite.find(:users, skip: 10)
        assert_equal 'user11', results.first["username"]
      end
    end

    describe 'with order_by and direction' do
      it 'should find records' do
        results = @sqlite.find(:users, order_by: 'username', direction: 'asc', limit: 1)
        assert_equal 'user1', results.first["username"]
        results = @sqlite.find(:users, order_by: 'username', direction: 'desc', limit: 1)
        assert_equal 'user9', results.first["username"]
      end
    end

    describe '#fields_for' do
      it 'should find fields given results' do        
        assert_equal ["id", "username", "age"], @sqlite.fields_for(@sqlite.find(:users))
      end
    end
  end

  describe '#create' do
    before do
      @previousCount = @sqlite.find(:users, limit: 1000).count
      @sqlite.create(:users, id: 999, username: 'new_user', age: 100)
      @newUser = @sqlite.find(:users, 
        limit: 1000, order_by: 'id', direction: 'desc', limit: 1).first
    end
    
    it 'insert a new record into the collection' do
      assert_equal @previousCount + 1, @sqlite.find(:users, limit: 1000).count
    end

    it 'should create new record with given attributes' do
      assert_equal 'new_user', @newUser["username"]
      assert_equal 100, @newUser["age"].to_i
    end
  end

  describe '#update' do
    before do
      @previousCount = @sqlite.find(:users, limit: 1000).count
      @userBeforeUpdate = @sqlite.find(:users, 
        limit: 1000, order_by: 'id', directon: 'desc', limit: 1).first
      @sqlite.update(:users, @userBeforeUpdate["id"], username: 'updated_name')
      @userAfterUpdate = @sqlite.find(:users, 
        limit: 1000, order_by: 'id', directon: 'desc', limit: 1).first
    end
    
    it 'should maintain collection count after update' do
      assert_equal @previousCount , @sqlite.find(:users, limit: 1000).count
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
      @previousCount = @sqlite.find(:users, limit: 1000).count
      @firstUser = @sqlite.find(:users, 
        limit: 1000, order_by: 'id', directon: 'asc', limit: 1).first
      @sqlite.delete(:users, @firstUser["id"])
    end
    
    it 'should reduce collection record count by 1' do
      assert_equal @previousCount - 1, @sqlite.find(:users, limit: 1000).count
    end

    it 'should delete record with given id' do
      newFirst = @sqlite.find(:users, 
              limit: 1000, order_by: 'id', directon: 'asc', limit: 1).first
      assert @firstUser["id"] != newFirst["id"]
    end
  end

  describe '#connected?' do
    it 'should be connected' do
      assert @sqlite.connected?
    end
  end

  describe '#close' do
    it 'should close connection' do
      @sqlite.close
      assert !@sqlite.connected?
    end
  end

  describe '#schema' do
    it 'should return schema for users table' do
      schema = @sqlite.schema(:users)
      assert_equal 3, schema.length
      assert_equal "id", schema.first["field"]
      assert_equal "username", schema.second["field"]
      assert_equal "age", schema.third["field"]
    end
  end    
end