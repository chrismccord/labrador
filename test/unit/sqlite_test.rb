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
end