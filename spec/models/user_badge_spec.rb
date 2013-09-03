require 'spec_helper'

describe BadgeGirl::UserBadge do
  let(:badge) do
    BadgeGirl.define do
      id 1234
      key :test_badge
      level 1

      component(:test_comp) { }
    end
  end

  let(:user) { User.create(name: 'Test User') }

  describe 'validations' do
    let(:user_badge) { BadgeGirl::UserBadge.new(user: user, badge_id: badge.id, goal: 1) }

    it 'is valid by default' do
      user_badge.should be_valid
    end

    it 'should not be valid when user is missing' do
      user_badge.user = nil
      user_badge.should_not be_valid
    end

    it 'should not be valid when badge is missing' do
      user_badge.badge_id = nil
      user_badge.should_not be_valid
    end

    it 'should be valid when progress is equal to goal' do
      user_badge.progress = 1
      user_badge.should be_valid
    end

    it 'should not be valid when progress is greater than goal' do
      user_badge.progress = 2
      user_badge.should_not be_valid
    end

    it 'should not be valid when user has same badge on same resource' do
      BadgeGirl::UserBadge.create(user: user, badge_id: badge.id, goal: 1)
      user_badge.should_not be_valid
    end

    it 'should be valid when user has same badge on different resource' do
      BadgeGirl::UserBadge.create(user: user, badge_id: badge.id, goal: 1)
      user_badge.resource = User.create(name: 'other user')
      user_badge.should be_valid
    end
  end

  describe '::find_or_create' do
    it 'should create new record if not exist' do
      expect {
        BadgeGirl::UserBadge.find_or_create(user.id, badge)
      }.to change(BadgeGirl::UserBadge, :count).by(1)
    end

    it 'should return existing record' do
      original_badge = BadgeGirl::UserBadge.find_or_create(user.id, badge)
      user_badge = nil

      expect {
        user_badge = BadgeGirl::UserBadge.find_or_create(user.id, badge)
      }.to_not change(BadgeGirl::UserBadge, :count)

      user_badge.should == original_badge
    end
  end

  describe '::create_badge' do
    context 'persisted' do
      subject { BadgeGirl::UserBadge.create_badge(user.id, badge) }

      it 'should create badge with underlying components by default' do
        subject.should be_persisted
        subject.badge_components.should have(1).item
      end

      context 'delegated attributes' do
        before do
          subject.badge.stub(name: 'funky', description: 'monkey', image: 'sprite.png')
        end

        its(:name) { should == 'funky' }
        its(:description) { should == 'monkey' }
        its(:image) { should == 'sprite.png' }
      end
    end

    context 'not persisted' do
      subject { BadgeGirl::UserBadge.create_badge(user.id, badge, false) }

      it 'should not persist badge with false argument' do
        subject.should_not be_persisted
        subject.badge_components.should have(1).item
      end

      context 'delegated attributes' do
        before do
          subject.badge.stub(name: 'funky', description: 'monkey', image: 'sprite.png')
        end

        its(:name) { should == 'funky' }
        its(:description) { should == 'monkey' }
        its(:image) { should == 'sprite.png' }
      end
    end
  end

  describe '::available' do
    it 'returns badges with no progress' do
      earned = BadgeGirl.define do
        id 1234
        key :earned
        component(:earned) {}
      end

      in_progress = BadgeGirl.define do
        id 1235
        key :in_progress
        component(:in_progress) {}
      end

      available = BadgeGirl.define do
        id 1236
        key :available
        component(:available) {}
      end

      user_badges = [earned, in_progress, available].map do |b|
        BadgeGirl::UserBadge.create_badge(user.id, b)
      end

      earned_u, in_progress_u, available_u = *user_badges
      earned_u.update_attributes(progress: 1, complete: true)
      in_progress_u.update_attribute(:progress, 1)

      BadgeGirl::UserBadge.available(user).map(&:badge_id).should =~ [available_u.badge_id]
    end
  end

  describe '#update_progress' do
    let(:badge) do
      BadgeGirl.define do
        id 1234
        key :test_badge
        level 0

        component(:first, goal: 3) { @first }
        component(:second, goal: 4) { @second }
      end
    end

    let(:user_badge) { BadgeGirl::UserBadge.create_badge(user.id, badge) }

    context 'badge not earned' do
      let(:context) do
        obj = Object.new
        obj.instance_variable_set(:@first, 2)
        obj.instance_variable_set(:@second, 4)
        obj
      end

      it 'should update progress and goal' do
        user_badge.update_progress(context)
        user_badge.reload
        user_badge.progress.should == 6
        user_badge.goal.should == 7
        user_badge.complete.should be_false
      end

      it 'should update component progress' do
        user_badge.update_progress(context)

        comp = BadgeGirl::BadgeComponent.where(key: 'first').first
        comp.progress.should == 2
        comp.complete.should be_false

        comp = BadgeGirl::BadgeComponent.where(key: 'second').first
        comp.progress.should == 4
        comp.complete.should be_true
      end
    end

    context 'badge earned' do
      let(:context) do
        obj = Object.new
        obj.instance_variable_set(:@first, 3)
        obj.instance_variable_set(:@second, 4)
        obj
      end

      it 'should update progress and goal' do
        user_badge.update_progress(context)
        user_badge.reload
        user_badge.progress.should == 7
        user_badge.goal.should == 7
        user_badge.complete.should be_true
      end

      it 'should update component progress' do
        user_badge.update_progress(context)

        comp = BadgeGirl::BadgeComponent.where(key: 'first').first
        comp.progress.should == 3
        comp.complete.should be_true

        comp = BadgeGirl::BadgeComponent.where(key: 'second').first
        comp.progress.should == 4
        comp.complete.should be_true
      end
    end
  end

  describe '#percent_complete' do
    let(:badge) do
      BadgeGirl.define do
        id 1234
        key :test_badge
        level 0

        component(:first, goal: 3) { @first }
        component(:second, goal: 4) { @second }
      end
    end

    let(:user_badge) { BadgeGirl::UserBadge.create_badge(user.id, badge) }

    let(:context) do
      obj = Object.new
      obj.instance_variable_set(:@first, 2)
      obj.instance_variable_set(:@second, 3)
      obj
    end

    it 'should return percent complete of total progress for badge' do
      user_badge.update_progress(context)
      user_badge.percent_complete.should == 71
    end

    it 'should return 0 when badge has no components' do
      badge = BadgeGirl.define do
        id 1235
        key :no_component
        level 3
      end

      ub = BadgeGirl::UserBadge.create_badge(user.id, badge)
      ub.percent_complete.should == 0
    end
  end
end
