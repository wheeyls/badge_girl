module BadgeGirl
  module ModelExtensions
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def has_badges
        class_eval do
          has_many :badges, class_name: 'BadgeGirl::UserBadge', dependent: :destroy
        end
      end
    end
  end
end
