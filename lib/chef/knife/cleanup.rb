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

require 'chef/api_client'


module ServerCleanup
  class Cleanup < Chef::Knife

    deps do
      #require 'chef/cookbook_loader'
    end

    banner "knife cleanup"

    option :delete,
     :short => "-D",
     :long => "--delete",
     :description => "Delete the unused versions of the cookbooks",
     :boolean => true

    def run
      cookbooks
    end

    def cookbooks
      ui.msg "Searching for unused cookboks versions..."
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
      
      # Let see what cookbooks we have in use in environments
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
      
      print "\e[31mDeleting \e[0m" if config[:delete]
      puts "Cookbook Versions:"
      key_length = cbv.empty? ? 0 : cbv.keys.map {|name| name.size }.max + 2
      cbv.each_key do |cb|
        print "  #{cb.ljust(key_length)}"
        cbv[cb].each do |cb_ver|
          print "#{cb_ver} "
          if config[:delete]
            delete_cookbook(cb, cb_ver)
          end
        end
        print "\n"
      end
      
      if !config[:delete]
        puts "Not deleting unused cookbook versions; use --delete if you want them removed"
      end
      
    end
    
    def delete_cookbook(cb, cb_ver)
      rest.delete_rest("cookbooks/#{cb}/#{cb_ver}")
      print ". "
    end
  end
end
