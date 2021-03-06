#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'
require_relative '../../ruby_task_helper/files/task_helper.rb'

class RegisterRunnerTask < TaskHelper
  def task(**kwargs)
    host    = kwargs[:url]
    options = kwargs.reject { |key, _| %i[_task _installdir url].include?(key) }
    uri     = URI.parse("#{host}/api/v4/runners")
    headers = {
      'Accept'       => 'application/json',
      'Content-Type' => 'application/json'
    }

    http         = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https')
    request      = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = options.to_json
    response     = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      msg = "Gitlab runner failed to register: #{response.message}"
      raise TaskHelper::Error.new(msg, 'bolt-plugin/gitlab-ci-runner-register-error')
    end
  end
end

RegisterRunnerTask.run if $PROGRAM_NAME == __FILE__
