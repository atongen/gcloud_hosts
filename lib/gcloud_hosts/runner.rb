require 'json'

module GcloudHosts
  class Runner

    def initialize(args)
      @options = Options.new(args).options
    end

    def run!
      project = @options[:project].to_s.strip
      if @options[:clear]
        if project != ""
          raise ArgumentError.new("Cannot specify 'clear' and 'project' at the same time.")
        end
      end
      if project == ""
        project = env["core"]["project"].to_s.strip
      end

      backup = @options[:backup] ||
        @options[:file] + '.bak'

      if @options[:clear]
        Updater.clear(@options[:file], backup, @options[:dry_run])
      else
        if project == ""
          raise AuthError.new("No gcloud project specified.")
        end
        if @options[:domain]
          domain = @options[:domain].to_s.strip
        else
          domain = "c.#{project}.internal"
        end

        if @options[:delete]
          new_hosts_list = []
        else
          new_hosts_list = Hosts.hosts(@options[:gcloud], project, @options[:network], domain, @options[:public], @options[:exclude_public])
        end
        Updater.update(new_hosts_list.join("\n"), project, @options[:file], backup, @options[:dry_run], @options[:delete])
      end
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
