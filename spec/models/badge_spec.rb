require 'spec_helper'

describe BadgeGirl::Badge do
  context 'filters' do
    describe '::find_by_key' do
      it 'should return badge with matching key' do
        badge1 = BadgeGirl::Badge.create(id: 1234, key: :test_key)
        BadgeGirl::Badge.create(id: 1235, key: :other_key)

        BadgeGirl::Badge.find_by_key('test_key').first.should == badge1
      end
    end

    describe '::excluding' do
      it 'should return badges that do not have arg ids' do
        badge1 = BadgeGirl::Badge.create(id: 1234, key: :test_key)
        badge2 = BadgeGirl::Badge.create(id: 1235, key: :other_key)
        badge3 = BadgeGirl::Badge.create(id: 1236, key: :final_key)

        BadgeGirl::Badge.excluding([badge1.id]).to_a.should =~ [badge2, badge3]
      end
    end

    describe '::tracked' do
      it 'should return badges that are not manual' do
        BadgeGirl::Badge.create(id: 1234, key: :test_key)
        badge = BadgeGirl::Badge.create(id: 1235, key: :other_key, components: [1])
        BadgeGirl::Badge.tracked.to_a.should == [badge]
      end
    end
  end

  let(:badge) { BadgeGirl::Badge.create(id: 1234, key: :test_key) }

  describe '#name' do
    it 'should look up name in translation file' do
      I18n.should_receive(:t).with('users.badges.test_key.name').and_return('funky')
      badge.name.should == 'funky'
    end
  end

  describe '#description' do
    it 'should look up description in translation file' do
      I18n.should_receive(:t).with('users.badges.test_key.description').and_return('monkey')
      badge.description.should == 'monkey'
    end
  end

  describe '#image' do
    it 'should return image path' do
      badge.image.should == 'user-badges/test_key.png'
    end

    it 'can lookup image by different size' do
      badge.image(:small).should == 'user-badges/test_key_small.png'
    end
  end

  describe '#goal' do
    subject(:badge) do
      BadgeGirl.define do
        id 1234
        key :test_badge
        level 0

        component(:review, goal: 2) {}
        component(:comment, goal: 3) {}
      end
    end

    its(:goal) { should == 5 }
  end
end
