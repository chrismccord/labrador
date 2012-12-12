require 'test_helper'
require 'minitest/autorun'

describe Labrador::Session do

  before do
    @app = Labrador::App.find_all_from_path("test/fixtures/apps").first
    @adapter = @app.adapters.first
    Labrador::Session.clear_all
  end

  describe 'self#add' do
    it 'adds sesion hash to Session store' do
      assert_equal 0, Labrador::Session.active.count
      assert Labrador::Session.add "name" => "test"
      assert_equal 1, Labrador::Session.active.count
    end
  end  

  describe 'self#active' do
    it 'returns array of active sessions' do
      Labrador::Session.clear_all
      Labrador::Session.add "name" => "test"
      assert_equal 1, Labrador::Session.active.count
    end
  end

  describe 'self#clear_all' do
    before do
      Labrador::Session.add "name" => "test"
    end

    it 'clears all the active sesions' do
      assert_equal 1, Labrador::Session.active.count
      Labrador::Session.clear_all
      assert_equal 0, Labrador::Session.active.count
    end
  end
end

