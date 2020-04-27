# frozen_string_literal: true

module APeye
  # Runtime errors occurr during API requests because they could not
  # be detected before an action is processed.
  class RuntimeError < StandardError
  end
end
