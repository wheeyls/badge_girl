module BadgeGirl
  require 'ambry'

  class Badge
    extend Ambry::Model

    field :id, :key, :level, :components

    filters do
      def find_by_key(arg)
        find { |b| b.key.to_s == arg.to_s }
      end

      def excluding(ids)
        find { |b| !ids.include?(b.id) }
      end

      def tracked
        find { |b| b.components.present? }
      end
    end

    def i18n_lookup(field)
      "users.badges.#{key}.#{field}"
    end

    %i[name description].each do |method|
      define_method(method) do
        I18n.t i18n_lookup(method)
      end
    end

    def image(size = '')
      image_name = size.blank? ? key : "#{key}_#{size}"
      "user-badges/#{image_name}.png"
    end

    def goal
      components.present? ? components.map(&:goal).reduce(:+) : 1
    end
  end
end
