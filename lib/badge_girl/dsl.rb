module BadgeGirl
  def self.define(&block)
    dsl = Dsl.new
    dsl.instance_eval(&block)
    dsl.create_badge
  end

  class Dsl
    def attributes
      @attributes ||= {}
    end

    %i[id key level].each do |method|
      define_method(method) do |value|
        attributes.merge! method => value
      end
    end

    def components
      @components ||= []
    end

    def component(key, goal: 1, &block)
      components.push(
        BadgeGirl::Component.create(
          id: "#{attributes[:id]}:#{key}",
          key: key,
          badge_id: attributes[:id],
          goal: goal,
          block: block
        )
      )
    end

    def create_badge
      new_badge = BadgeGirl::Badge.new(attributes)
      new_badge.components = components
      new_badge.save
    end
  end
end
