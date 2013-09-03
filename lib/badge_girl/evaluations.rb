module BadgeGirl
  module Evaluations
    def evaluate_on(actions, *badge_keys, user_method: :current_user)
      badge_keys.each do |badge_key|
        badge = Badge.find_by_key(badge_key).first
        Array.wrap(actions).each do |action|
          ActiveSupport::Notifications.subscribe("badge_girl.#{action}") do |*args|
            event = ActiveSupport::Notifications::Event.new(*args)
            controller = event.payload[:controller]
            user = controller.send(user_method)
            if user.present?
              user_badge = UserBadge.find_or_create(user.id, badge)
              user_badge.update_progress(controller)
            end
          end
        end
      end
    end
  end
end
