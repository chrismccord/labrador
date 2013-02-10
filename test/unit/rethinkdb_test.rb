require 'test_helper'
require 'minitest/autorun'

describe Labrador::RethinkDB do

  before do
    config = YAML.load(File.read(Rails.root.join("config/database.yml")))["adapter_test"]["rethinkdb"]
    @rethinkdb = Labrador::RethinkDB.new(
      host: config["host"],
      port: config["port"],
      database: config["database"]
    )
    database = @rethinkdb.database
    @rethinkdb.r.db_drop(database).run if @rethinkdb.r.db_list.run.include?(database)
    @rethinkdb.r.db_create(database).run
    @rethinkdb.r.db(database).table_create('users').run
    1.upto(20) do |i|
      @rethinkdb.r.db(database).table('users').insert(
        username: "user#{i}", 
        age: i + 10
      ).run
    end
  end

  describe '#collections' do
    it "should list collections/tables" do
      assert_equal ["users"], @rethinkdb.collections
    end
  end

  describe '#find' do
    describe 'with no options' do
      it 'should find records' do
        results = @rethinkdb.find(:users)
        assert results.any?
      end
    end

    describe 'with limit' do
      it 'should find records' do
        results = @rethinkdb.find(:users, limit: 20)
        assert_equal 20, results.count
      end
    end

    describe 'with offset/skip' do
      it 'should find records' do
        results = @rethinkdb.find(:users, skip: 10, order_by: 'age', direction: 'asc')
        assert_equal 'user11', results.first["username"]
      end
    end

    describe 'with order_by and direction' do
      it 'should find records' do
        results = @rethinkdb.find(:users, order_by: 'username', direction: 'asc', limit: 1)
        assert_equal 'user1', results.first["username"]
        results = @rethinkdb.find(:users, order_by: 'username', direction: 'desc', limit: 1)
        assert_equal 'user9', results.first["username"]
      end
    end

    describe '#fields_for' do
      it 'should find fields given results' do
        fields = @rethinkdb.fields_for(@rethinkdb.find(:users))
        assert_equal ["id", "age", "username"].sort, fields.sort
      end
    end
  end


  describe '#create' do
    before do
      @previousCount = @rethinkdb.find(:users, limit: 1000).count
      @rethinkdb.create(:users, username: 'new_user', age: 100)
      @newUser = @rethinkdb.find(:users, 
        limit: 1000, order_by: 'age', direction: 'desc', limit: 1).first
    end
    
    it 'insert a new record into the collection' do
      assert_equal @previousCount + 1, @rethinkdb.find(:users, limit: 1000).count
    end

    it 'should create new record with given attributes' do
      assert_equal 'new_user', @newUser["username"]
      assert_equal 100, @newUser["age"]
    end
  end

  describe '#update' do
    before do
      @previousCount = @rethinkdb.find(:users, limit: 1000).count
      @userBeforeUpdate = @rethinkdb.find(:users, 
        limit: 1000, order_by: 'id', directon: 'desc', limit: 1).first
      @rethinkdb.update(:users, @userBeforeUpdate["id"], username: 'updated_name')
      @userAfterUpdate = @rethinkdb.find(:users, 
        limit: 1000, order_by: 'id', directon: 'desc', limit: 1).first
    end
    
    it 'should maintain collection count after update' do
      assert_equal @previousCount, @rethinkdb.find(:users, limit: 1000).count
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
      @previousCount = @rethinkdb.find(:users, limit: 1000).count
      @firstUser = @rethinkdb.find(:users, 
        limit: 1000, order_by: 'id', directon: 'asc', limit: 1).first
      @rethinkdb.delete(:users, @firstUser["id"])
    end
    
    it 'should reduce collection record count by 1' do
      assert_equal @previousCount - 1, @rethinkdb.find(:users, limit: 1000).count
    end

    it 'should delete record with given id' do
      newFirst = @rethinkdb.find(:users, 
        limit: 1000, order_by: 'id', directon: 'asc', limit: 1).first
      assert @firstUser["id"] != newFirst["id"]
    end
  end

  describe '#connected?' do
    it 'should be connected' do
      assert @rethinkdb.connected?
    end
  end

  describe '#close' do
    it 'should close connection' do
      @rethinkdb.close
      assert !@rethinkdb.connected?
    end
  end

  describe '#schema' do
    it 'should return empty array' do
      assert_equal [], @rethinkdb.schema(:users)
    end
  end
end