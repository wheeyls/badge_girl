module BadgeGirl
  module ControllerExtensions
    def self.included(base)
      base.after_filter do |controller|
        ActiveSupport::Notifications.instrument(
          "badge_girl.#{controller_path}##{action_name}", controller: controller
        )
      end
    end
  end
end
