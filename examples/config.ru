# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
$LOAD_PATH.unshift(File.expand_path(__dir__))

require 'rapid'
require 'rapid/rack'
require 'core_api/base'

use Rapid::Rack, CoreAPI::Base, '/core/v1', development: true

app = proc do
  [400, { 'Content-Type' => 'text/plain' }, ['Rapid Example API Server. Make a request to a an example API for example /core/v1.']]
end

run app
