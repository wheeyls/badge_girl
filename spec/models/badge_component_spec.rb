require 'spec_helper'

describe BadgeGirl::BadgeComponent do
  let(:badge) do
    BadgeGirl.define do
      id 1234
      key :test_badge
      level 0

      component(:first, goal: 3) { @first }
      component(:truthy) { true }
      component(:falsy) { false }
    end
  end

  let(:user) { User.create(name: 'Test User') }
  let(:user_badge) { BadgeGirl::UserBadge.create_badge(user.id, badge) }
  let(:badge_component) { user_badge.badge_components.first }

  let(:context) do
    obj = Object.new
    obj.instance_variable_set(:@first, 2)
    obj
  end

  describe 'validations' do
    context 'progress numericality' do
      it 'should be valid when progress less than goal' do
        bc = BadgeGirl::BadgeComponent.new(progress: 2, goal: 3)
        bc.should be_valid
      end

      it 'should be valid when progress equals goal' do
        bc = BadgeGirl::BadgeComponent.new(progress: 3, goal: 3)
        bc.should be_valid
      end

      it 'should not have progress greater than goal' do
        bc = BadgeGirl::BadgeComponent.new(progress: 4, goal: 3)
        bc.should_not be_valid
      end
    end
  end

  describe '#evaluate_progress' do
    it 'should return its progress' do
      badge_component.evaluate_progress(context).should == 2
    end

    it 'should return 1 for truthy' do
      comp = user_badge.badge_components.where(key: 'truthy').first
      comp.evaluate_progress(context).should == 1
    end

    it 'should return 0 for falsy' do
      comp = user_badge.badge_components.where(key: 'falsy').first
      comp.evaluate_progress(context).should == 0
    end
  end

  describe '#update_progress' do
    it 'should update progress and complete state' do
      badge_component.should_receive(:evaluate_progress).and_return(2,3)

      badge_component.update_progress(context)
      badge_component.reload
      badge_component.progress == 2
      badge_component.complete.should be_false

      badge_component.update_progress(context)
      badge_component.reload
      badge_component.progress == 3
      badge_component.complete.should be_true
    end

    it 'should not allow progress to exceed goal' do
      badge_component.should_receive(:evaluate_progress).and_return(5)

      badge_component.update_progress(context)
      badge_component.reload
      badge_component.progress == 3
      badge_component.complete.should be_true
    end
  end

  describe '#percent_complete' do
    it 'should return percent complete' do
      badge_component.progress = 1
      badge_component.percent_complete.should == 33
    end
  end
end
