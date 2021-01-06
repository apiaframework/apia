# frozen_string_literal: true

require 'rapid/error'

module Rapid
  class ScopeNotGrantedError < Rapid::Error

    code :scope_not_granted
    http_status 403
    description 'The scope required for this endpoint has not been granted to the authenticating identity'

    field :scopes, [:string]

  end
end
