require 'json'

module GcloudHosts
  module Hosts

    def self.instances(gcloud_path, project, network)
      JSON.parse(%x{ #{gcloud_path} compute instances list --project #{project} --format json 2>/dev/null })
        .select { |i| i["status"] == "RUNNING" }
        .select do |i|
          network.to_s.strip == "" ||
          i["networkInterfaces"].any? { |ni| ni["network"] == network }
        end.sort { |x,y| x["name"] <=> y["name"] }
    end

    def self.hosts(gcloud_path, project, network, domain, public_pattern, exclude_public)
      instances(gcloud_path, project, network).inject([]) do |list, i|
        begin
          if public_pattern.to_s.strip != "" && i["name"].downcase.include?(public_pattern)
            if !exclude_public
              # get external ip address
              i["networkInterfaces"].each do |ni|
                ni["accessConfigs"].each do |ac|
                  if ac["name"].downcase.include?("nat") && ac["type"].downcase.include?("nat")
                    if ip = ac["natIP"]
                      str = "#{ip} #{i["name"]}"
                      str << " #{i["name"]}.#{domain}" unless domain.to_s.strip == ""
                      list << str
                      raise HostError.new
                    end
                  end
                end
              end
            end
          else
            # get first internal private network interface
            i["networkInterfaces"].each do |ni|
              if ni["name"] == "nic0"
                if ip = ni["networkIP"]
                  str = "#{ip} #{i["name"]}"
                  str << " #{i["name"]}.#{domain}" unless domain.to_s.strip == ""
                  list << str
                  raise HostError.new
                end
              end
            end
          end
        rescue HostError; end
        list
      end
    end
  end
end
