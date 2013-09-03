require 'spec_helper'

describe BadgeGirl do
  describe BadgeGirl::Dsl do
    subject { BadgeGirl::Dsl.new }

    it 'responds to id' do
      subject.should respond_to :id
    end

    it 'responds to key' do
      subject.should respond_to :key
    end

    it 'responds to level' do
      subject.should respond_to :level
    end

    it 'responds to component' do
      subject.should respond_to :component
    end

    describe '#create_badge' do
      it 'should return a new instance of a badge' do
        subject.create_badge.should be_a BadgeGirl::Badge
      end
    end
  end

  describe '::define' do
    let(:badge) do
      BadgeGirl.define do
        id 1234
        key :test_badge
        level 0

        component(:test_component, goal: 3) {}
        component(:test_component_1) {}
      end
    end

    it 'should create a new badge based on block' do
      badge.should be_a BadgeGirl::Badge
    end

    it 'should store the id, key and level' do
      badge.id.should == 1234
      badge.key.should == :test_badge
      badge.level.should == 0
    end

    context 'components' do
      subject { badge.components.first }

      it 'should have a component' do
        badge.components.should have(2).items
        subject.should be_a BadgeGirl::Component
      end

      its(:id) { should == '1234:test_component' }
      its(:key) { should == :test_component }
      its(:badge_id) { should == 1234 }
      its(:goal) { should == 3 }
      its(:block) { should be_a Proc }
    end
  end
end
