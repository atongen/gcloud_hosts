require 'json'

module GcloudHosts
  class Runner
    def initialize
      @options = Options.options
    end

    def run!
      project = @options[:project]
      if project.to_s.strip == ""
        project = env["core"]["project"]
      end
      if project.to_s.strip == ""
        raise AuthError.new("No gcloud project specified.")
      end

      if @options[:domain]
        domain = @options[:domain].to_s.strip
      else
        domain = "c.#{project}.internal"
      end

      new_hosts_list = Hosts.hosts(@options[:gcloud], project, @options[:network], domain, @options[:public])
      Updater.update(new_hosts_list.join("\n"), project, @options[:file], @options[:dry_run])
    end

    private

    def env
      @env ||= begin
        gcloud = @options[:gcloud]
        if gcloud.to_s.strip == ""
          raise AuthError.new("gcloud command not found.")
        end
        env = JSON.parse(%x{ #{gcloud} config list --format json 2>/dev/null })
        if env["core"]["account"].to_s.strip == ""
          raise AuthError.new("Please log into gcloud.")
        end
        env
      end
    end
  end
end
