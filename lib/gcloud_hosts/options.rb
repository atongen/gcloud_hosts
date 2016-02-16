require 'optparse'

module GcloudHosts
  class Options

    attr_reader :options

    def initialize(args)
      @options = {
        gcloud: %x{ which gcloud 2>/dev/null }.to_s.strip,
        project: nil,
        network: nil,
        domain: nil,
        public: nil,
        file: '/etc/hosts',
        backup: nil,
        dry_run: false,
        delete: false
      }
      parser.parse!(args)
    end

    private

    def parser
      @parser ||= begin
        OptionParser.new do |opts|
          opts.banner = "Usage: $ gcloud_hosts [options]"
          opts.on('-g', '--gcloud GCLOUD', "Path to gcloud executable. Defaults to PATH location") do |opt|
            @options[:project] = opt
          end
          opts.on('-p', '--project PROJECT', "gcloud project to use. Defaults to default gcloud configuration.") do |opt|
            @options[:project] = opt
          end
          opts.on('-n', '--network NETWORK', "gcloud network to filter on. Defaults nil.") do |opt|
            @options[:network] = opt
          end
          opts.on('-d', '--domain DOMAIN', "Domain to append to all hosts. Default: \"c.[PROJECT].internal\"") do |opt|
            @options[:domain] = opt
          end
          opts.on('--public PUBLIC', "Pattern to match for public/bastion hosts. Use public IP for these. Defaults to nil") do |opt|
            @options[:public] = opt
          end
          opts.on('-f', '--file FILE', "Hosts file to update. Defaults to /etc/hosts") do |opt|
            @options[:file] = opt
          end
          opts.on('-b', '--backup BACKUP', "Path to backup original hosts file to. Defaults to FILE with '.bak' extension appended.") do |opt|
            @options[:file] = opt
          end
          opts.on('--[no-]dry-run', "Dry run, do not modify hosts file. Defaults to false") do |opt|
            @options[:dry_run] = opt
          end
          opts.on('--[no-]delete', "Delete the project from hosts file. Defaults to false") do |opt|
            @options[:delete] = opt
          end
          opts.on_tail("--help", "Show this message") do
            puts opts
            exit
          end
          opts.on_tail("--version", "Show version") do
            puts ::GcloudHosts::VERSION.join('.')
            exit
          end
        end
      end
    end
  end
end
