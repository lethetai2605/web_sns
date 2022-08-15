# Be sure to restart your server when you modify this file.
# frozen_string_literal: true

# This file contains settings for ActionController::ParamsWrapper which
# is enabled by default.

ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

# To enable root element in JSON for ActiveRecord objects.
# ActiveSupport.on_load(:active_record) do
#   self.include_root_in_json = true
# end