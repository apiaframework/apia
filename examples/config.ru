# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
$LOAD_PATH.unshift(File.expand_path(__dir__))

require 'apia'
require 'apia/rack'
require 'core_api/base'

use Apia::Rack, CoreAPI::Base, '/core/v1', development: true

app = proc do
  [400, { 'Content-Type' => 'text/plain' }, ['Apia Example API Server. Make a request to a an example API for example /core/v1.']]
end

run app
