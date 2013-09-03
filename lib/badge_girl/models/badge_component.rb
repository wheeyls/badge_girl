module BadgeGirl
  class BadgeComponent < ActiveRecord::Base
    belongs_to :user_badge

    delegate :name, :description, to: :component

    validates :progress, numericality: { less_than_or_equal_to: :goal }

    def component
      @component ||= Component.find "#{user_badge.badge_id}:#{key}"
    end

    def evaluate_progress(context)
      value = context.instance_eval(&component.block)
      if !!value == value
        value = value ? 1 : 0
      end
      value
    end

    def update_progress(context)
      goal = component.goal
      value = evaluate_progress(context)
      value = [value, goal].min
      unless value == progress
        update_attributes(progress: value, complete: value == goal)
      end
    end

    def percent_complete
      [progress, goal].min * 100 / goal
    end
  end
end
