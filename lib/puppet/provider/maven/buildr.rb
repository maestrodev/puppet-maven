# Copyright 2011 MaestroDev
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

require 'puppet/resource'
require 'puppet/resource/catalog'
require 'rubygems'
require 'buildr'
require 'fileutils'

# Hack to make buildr think there is a rakefile in the directory
class << Buildr.application
  def rakefile; __FILE__; end
end

Puppet::Type.type(:maven).provide(:buildr) do
  desc "Maven download using Apache buildr."

  def create
    # Remote repositories to use
    repos = @resource[:repos]
    if repos.nil? || repos.empty?
      Buildr.repositories.remote << "http://repo1.maven.apache.org/maven2"
    else
      if repos.kind_of?(Array)
        Buildr.repositories.remote = repos
      else
        Buildr.repositories.remote << repos
      end
    end
    debug "Repositories to use: #{Buildr.repositories.remote.join(', ')}"
    
    full_id = @resource[:id]
    
    # Download the artifact fom the repo
    debug "Buildr downloading (if needed) repo file #{full_id} from #{Buildr.repositories.remote.join(', ')}"
    artifact = Buildr.artifact(full_id)
    artifact.invoke

    # Copy the file from the local repo to the destination
    path = artifact.to_s
    dest = @resource[:name]
    debug "Copying #{path} to #{dest}"
    FileUtils.cp path, dest
  end

  def destroy
    # no going back
    raise NotImplementedError
  end

  def exists?
    # we could check if the file exists in the local repo but Buildr will do that before attempting to download it
    return File.exists?(@resource[:name])
  end
end
