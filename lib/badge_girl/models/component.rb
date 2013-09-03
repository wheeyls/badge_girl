module BadgeGirl
  require 'ambry'

  class Component
    extend Ambry::Model

    field :id, :key, :badge_id, :goal, :block

    def badge
      @badge ||= Badge.find badge_id
    end

    def i18n_lookup(field)
      "users.badges.#{badge.key}.components.#{key}.#{field}"
    end

    %i[name description].each do |method|
      define_method(method) do
        I18n.t i18n_lookup(method)
      end
    end
  end
end
