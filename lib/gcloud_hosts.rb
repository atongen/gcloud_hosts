require 'gcloud_hosts/version'
require 'gcloud_hosts/options'
require 'gcloud_hosts/hosts'
require 'gcloud_hosts/updater'
require 'gcloud_hosts/runner'

module GcloudHosts
  class HostError < StandardError; end
  class UpdaterError < StandardError; end
  class AuthError < StandardError; end
end
