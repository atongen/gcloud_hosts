module GcloudHosts
  # Updater implements a very state machine which is used to update
  # content between zero or more blocks of content which start and end
  # with pre-defined "marker" lines.
  module Updater

    module Marker
      BEFORE = 0
      INSIDE = 1
      AFTER = 2
    end

    def self.update(new_hosts, project, file, backup_file, dry_run, delete)
      start_marker = get_start_marker(project)
      end_marker = get_end_marker(project)

      old_hosts = File.read(file)

      if old_hosts.include?(start_marker) && old_hosts.include?(end_marker)
        # valid markers exists
        if delete
          new_content = delete_project_hosts(old_hosts, start_marker, end_marker)
        else
          new_content = gen_new_hosts(old_hosts, new_hosts, start_marker, end_marker)
        end
        # remove zero or more white space characters at end of file with
        # a single new-line
        new_content.gsub!(/\s+$/, "\n")

        if dry_run
          puts new_content
        elsif new_content != old_hosts
          # backup old host file
          File.open(backup_file, 'w') { |f| f << old_hosts }
          # write new content
          File.open(file, 'w') { |f| f << new_content }
        end
      elsif old_hosts.include?(start_marker) || old_hosts.include?(end_marker)
        raise UpdaterError.new("Invalid marker present in existing hosts content")
      else
        # marker doesn't exist
        if delete
          new_content = old_hosts
        else
          new_content = [old_hosts, start_marker, new_hosts, end_marker].join("\n")
        end
        # remove one or more white space characters at end of file with
        # a single new-line
        new_content.gsub!(/\s+$/, "\n")

        if dry_run
          puts new_content
        elsif new_content != old_hosts
          # backup old host file
          File.open(backup_file, 'w') { |f| f << old_hosts }
          # write new content
          File.open(file, 'w') { |f| f << new_content }
        end
      end

      true
    end

    def self.gen_new_hosts(hosts, new_hosts, start_marker, end_marker)
      new_content = ''
      marker_state = Marker::BEFORE
      hosts.split("\n").each do |line|
        if line == start_marker
          if marker_state == Marker::BEFORE
            # transition to inside the marker
            new_content << start_marker + "\n"
            marker_state = Marker::INSIDE
            # add new host content
            new_hosts.split("\n").each do |host|
              new_content << host + "\n"
            end
          else
            raise UpdaterError.new("Invalid marker state")
          end
        elsif line == end_marker
          if marker_state == Marker::INSIDE
            # transition to after the marker
            new_content << end_marker + "\n"
            marker_state = Marker::AFTER
          else
            raise UpdaterError.new("Invalid marker state")
          end
        else
          case marker_state
          when Marker::BEFORE, Marker::AFTER
            new_content << line + "\n"
          when Marker::INSIDE
            # skip everything between old markers
            next
          end
        end
      end
      new_content
    end

    def self.clear(file, backup_file, dry_run)
      old_hosts = File.read(file)
      new_content = old_hosts.dup

      markers = old_hosts.each_line.map do |line|
        regex = "\# (START|END) GCLOUD HOSTS - (.+) \#"
        if m = line.match(/^#{regex}$/)
          m[2]
        end
      end.compact.uniq

      markers.each do |project|
        start_marker = get_start_marker(project)
        end_marker = get_end_marker(project)

        new_content = delete_project_hosts(new_content, start_marker, end_marker)
      end
      new_content.gsub!(/\s+$/, "\n")

      if dry_run
        puts new_content
      elsif new_content != old_hosts
        # backup old host file
        File.open(backup_file, 'w') { |f| f << old_hosts }
        # write new content
        File.open(file, 'w') { |f| f << new_content }
      end
    end

    def self.delete_project_hosts(hosts, start_marker, end_marker)
      new_content = ''
      marker_state = Marker::BEFORE
      hosts.split("\n").each do |line|
        if line == start_marker
          if marker_state == Marker::BEFORE
            marker_state = Marker::INSIDE
            # don't add any content, we're deleting this block
          else
            raise UpdaterError.new("Invalid marker state")
          end
        elsif line == end_marker
          if marker_state == Marker::INSIDE
            marker_state = Marker::AFTER
          else
            raise UpdaterError.new("Invalid marker state")
          end
        else
          case marker_state
          when Marker::BEFORE, Marker::AFTER
            new_content << line + "\n"
          when Marker::INSIDE
            # skip everything between old markers
            next
          end
        end
      end
      new_content
    end

    def self.get_start_marker(project)
      "# START GCLOUD HOSTS - #{project} #"
    end

    def self.get_end_marker(project)
      "# END GCLOUD HOSTS - #{project} #"
    end

  end
end
