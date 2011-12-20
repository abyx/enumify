require 'spec_helper'

class Model < SuperModel::Base
  include ActiveModel::Validations
  extend Enumify::Model
  def self.scope(name,hash={}) self end
  def self.where(hash={}) self end

  enum :status, [:available, :canceled, :completed]
  
end

describe Enumify do

  before(:each) do
    @obj = Model.new(:status => :available)
  end

  describe "short hand methods" do
    describe "question mark (?)" do
      it "should return true if value of enum equals a value" do
        @obj.should be_available
      end

      it "should return false if value of enum is different" do
        @obj.should_not be_canceled
      end

    end

    describe "exclemation mark (!)" do
      it "should change the value of the enum to the methods value" do
        @obj.canceled!
        @obj.status.should == :canceled
      end
    end

    it "should have two shorthand methods for each possible value" do
      Model::STATUSES.each do |val|
        @obj.should respond_to("#{val}?")
        @obj.should respond_to("#{val}!")
      end
    end
  end

  describe "getting value" do
    it "should always return the enums value as a symbol" do
      @obj.status.should == :available
      @obj.status = "canceled"
      @obj.status.should == :canceled
    end

  end

  describe "setting value" do
    it "should except values as symbol" do
      @obj.status = :canceled
      @obj.should be_canceled
    end

    it "should except values as string" do
      @obj.status = "canceled"
      @obj.should be_canceled
    end
  end

  describe "validations" do
    it "should not except a value outside the given list" do
      @obj = Model.new(:status => :available)
      @obj.status = :foobar
      @obj.should_not be_valid
    end

    it "should except value in the list" do
      @obj = Model.new(:status => :available)
      @obj.status = :canceled
      @obj.should be_valid
    end
  end

  describe "callbacks" do
    it "should receive a callback on change of value" do
      @obj.should_receive(:status_changed).with(:available,:canceled)
      @obj.canceled!
    end

    it "should not receive a callback on initial value" do
      @obj = Model.new
      @obj.should_not_receive(:status_changed).with(nil, :canceled)
      @obj.canceled!
      end

    it "should not receive a callback on value change to same" do
      @obj.should_not_receive(:status_changed).with(:available, :available)
      @obj.available!
    end

  end

  it "class should have a CONST that holds all the available options of the enum" do
    Model::STATUSES.should == [:available, :canceled, :completed]
  end

end
