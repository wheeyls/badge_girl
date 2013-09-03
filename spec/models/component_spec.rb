require 'spec_helper'

describe BadgeGirl::Component do
  let(:badge) { BadgeGirl::Badge.create(id: 1234, key: :test_key) }
  let(:component) do
    BadgeGirl::Component.create(id: '1234:test_component', key: :test_component,
                                badge_id: badge.id, goal: 2, block: proc {})
  end

  describe '#badge' do
    it 'should return the parent badge' do
      component.badge.should == badge
    end
  end

  describe '#name' do
    it 'should look up name in translation file' do
      I18n.should_receive(:t).with('users.badges.test_key.components.test_component.name').and_return('funky')
      component.name.should == 'funky'
    end
  end

  describe '#description' do
    it 'should look up description in translation file' do
      I18n.should_receive(:t).with('users.badges.test_key.components.test_component.description').and_return('monkey')
      component.description.should == 'monkey'
    end
  end
end
