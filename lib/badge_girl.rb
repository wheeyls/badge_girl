require 'nilify_blanks'
require 'valium'

require 'badge_girl/dsl'
require 'badge_girl/evaluations'

require 'badge_girl/models/badge'
require 'badge_girl/models/component'

module BadgeGirl
  class Engine < Rails::Engine
    initializer 'badge_girl.controller' do
      ActiveSupport.on_load(:action_controller) do
        require 'badge_girl/controller_extensions'
        include BadgeGirl::ControllerExtensions
      end
    end

    initializer 'badge_girl.model' do
      ActiveSupport.on_load(:active_record) do
        require 'badge_girl/model_extensions'
        include BadgeGirl::ModelExtensions

        require 'badge_girl/models/user_badge'
        require 'badge_girl/models/badge_component'
      end
    end
  end
end
