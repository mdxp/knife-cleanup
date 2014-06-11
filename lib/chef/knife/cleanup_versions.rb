#
# Author:: Marius Ducea (<marius.ducea@gmail.com>)
# Copyright:: Copyright (c) 2013 Marius Ducea
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module ServerCleanup
  class CleanupVersions < Chef::Knife

    deps do
      require 'fileutils'
      require 'chef/api_client'
      require 'chef/cookbook_loader'
      require 'chef/knife/cookbook_download'
    end

    banner "knife cleanup versions (options)"

    option :delete,
     :short => "-D",
     :long => "--delete",
     :description => "Delete the unused versions of the cookbooks",
     :boolean => true

    option :backup,
     :short => "-B",
     :long => "--backup",
     :description => "Backup the cookbook versions that are being deleted",
     :boolean => true,
     :default => false

    def run
      cookbooks
    end

    def cookbooks
      ui.msg "Searching for unused cookbook versions..."
      all_cookbooks = rest.get_rest("/cookbooks?num_versions=all")
      latest_cookbooks = rest.get_rest("/cookbooks?latest")
      
      # All cookbooks
      cbv = all_cookbooks.inject({}) do |collected, ( cookbook, versions )|
        collected[cookbook] = versions["versions"].map {|v| v['version']}
        collected
      end
      
      # Get the latest cookbooks
      latest = latest_cookbooks.inject({}) do |collected, ( cookbook, versions )|
        collected[cookbook] = versions["versions"].map {|v| v['version']}
        collected
      end
      
      latest.each_key do |cb|
        cbv[cb].delete(latest[cb][0])
      end
      
      # Let see what cookbooks we have in use in all environments
      Chef::Environment.list.each_key do |env_list|
        env = Chef::Environment.load(env_list)
        next unless !env.cookbook_versions.empty?
        env.cookbook_versions.each_key do |cb|
          cb_ver = env.cookbook_versions[cb].split(" ").last
          begin
            cbv[cb].delete(cb_ver)
          rescue
            "Skipping..."
          end
        end
      end
      
      confirm("Do you really want to delete unused cookbook versions from the server")  if config[:delete]
      ui.msg "Cookbook Versions:"
      key_length = cbv.empty? ? 0 : cbv.keys.map {|name| name.size }.max + 2
      cbv.each_key do |cb|
        print "  #{cb.ljust(key_length)}"
        cbv[cb].each do |cb_ver|
          print "#{cb_ver} "
          if config[:delete]
            dir = ".cleanup/#{cb}/"
            backup_cookbook(cb,cb_ver,dir) if config[:backup]
            delete_cookbook(cb, cb_ver)
          end
        end
        print "\n"
      end
      
      if !config[:delete]
        ui.msg "Not deleting unused cookbook versions; use --delete if you want to remove them"
      end
      
    end
    
    def delete_cookbook(cb, cb_ver)
      ui.msg "Deleting cookbook #{cb} version #{cb_ver}"
      rest.delete_rest("cookbooks/#{cb}/#{cb_ver}")
      print ". "
    end

    def backup_cookbook(cb,cb_ver,dir)
      ui.msg "\nFist backing up cookbook #{cb} version #{cb_ver}"
      FileUtils.mkdir_p(dir)
      dld = Chef::Knife::CookbookDownload.new
      dld.name_args = [cb, cb_ver]
      dld.config[:download_directory] = dir
      dld.config[:force] = true
      begin
        dld.run
      rescue
        ui.msg "Failed to download cookbook #{cb} version #{cb_ver}... Skipping"
        FileUtils.rm_r(File.join(dir, cb + "-" + cb_ver))
      end
    end
  end
end
