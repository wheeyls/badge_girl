module BadgeGirl
  class UserBadge < ActiveRecord::Base
    nilify_blanks

    belongs_to :user
    has_many :badge_components, dependent: :destroy
    belongs_to :resource, polymorphic: true

    delegate :name, :description, :image, to: :badge

    validates :user_id, :badge_id, presence: true
    validates :progress, numericality: { less_than_or_equal_to: :goal }
    validates :badge_id, uniqueness: { scope: %i[user_id resource_id resource_type] }

    class << self
      def find_or_create(user_id, badge)
        where(user_id: user_id, badge_id: badge.id).first ||
          create_badge(user_id, badge)
      end

      def create_badge(user_id, badge, save = true)
        instance = self.new(
          user_id: user_id, badge_id: badge.id, level: badge.level,
          goal: badge.goal
        )

        (badge.components || []).each do |component|
          instance.badge_components.build(
            key: component.key.to_s,
            goal: component.goal
          )
        end

        instance.save if save
        instance
      end

      def available(user)
        current = user.badges.in_progress_or_earned.pluck(:badge_id)

        Badge.excluding(current).tracked.map { |b| create_badge(user.id, b, false) }
      end
    end

    scope :earned, -> {
      where(complete: true)
    }

    scope :in_progress, -> {
      where('user_badges.complete = ? and user_badges.progress > 0', false)
    }

    scope :in_progress_or_earned, -> {
      where('user_badges.progress > 0')
    }

    def badge
      @badge ||= Badge.find badge_id
    end

    def evaluate_progress
      badge_components.map{ |e| [e.progress, e.goal] }.transpose.map(&:sum)
    end

    def update_progress(context)
      badge_components.each { |bc| bc.update_progress(context) }

      progress, goal = evaluate_progress

      unless progress == self.progress
        update_attributes(
          progress: progress,
          goal: goal,
          complete: progress == goal
        )
      end
    end

    def percent_complete
      return 0 if badge.components.blank?

      numerator = 0
      denominator = 0
      badge_components.each do |bc|
        numerator += [bc.progress, bc.goal].min
        denominator += bc.goal
      end
      numerator * 100 / denominator
    end
  end
end
