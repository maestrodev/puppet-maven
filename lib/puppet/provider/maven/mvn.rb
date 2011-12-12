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
require 'fileutils'

Puppet::Type.type(:maven).provide(:mvn) do
  desc "Maven download using mvn command line."
  include Puppet::Util::Execution

  def create
    plugin_version = @resource[:pluginversion].nil? ? "2.4" : @resource[:pluginversion]

    # Remote repositories to use
    repos = @resource[:repos]
    if repos.nil? || repos.empty?
      repos = ["http://repo1.maven.apache.org/maven2"]
    elsif !repos.kind_of?(Array)
      repos = [repos]
    end
    repoid = @resource[:repoid]
    debug "Repositories to use: #{repos.join(', ')}"

    # Where to copy the file from the local repository
    dest = name

    full_id = @resource[:id]
    groupid = @resource[:groupid]
    artifactid = @resource[:artifactid]
    version = @resource[:version]
    packaging = @resource[:packaging]
    classifier = @resource[:classifier]
    options = @resource[:options]
    user = @resource[:user]
    user = user.nil? || user.empty? ? "root" : user
    group = @resource[:group]
    group = group.nil? || group.empty? ? "root" : group

    # Download the artifact fom the repo
    command_string = "-Dartifact=#{full_id}"
    msg = full_id
    if (full_id.nil?)
      command_string = "-DgroupId=#{groupid} -DartifactId=#{artifactid} -Dversion=#{version} "
      command_string = command_string + "-Dpackaging=#{packaging} " unless packaging.nil?
      command_string = command_string + "-Dclassifier=#{classifier}" unless classifier.nil?
      msg = "#{groupid}:#{artifactid}:#{version}:" + (packaging.nil? ? "" : packaging) + ":" + (classifier.nil? ? "" : classifier)
    end

    # set the repoId if specified
    command_string = command_string + " -DrepoId=#{repoid}" unless repoid.nil?

    debug "mvn downloading (if needed) repo file #{msg} to #{dest} from #{repos.join(', ')}"

    command = ["mvn org.apache.maven.plugins:maven-dependency-plugin:#{plugin_version}:get #{command_string} -DremoteRepositories=#{repos.join(',')} -Ddest=#{dest} -Dtransitive=false -Ppuppet-maven #{options}"]

    timeout = @resource[:timeout].nil? ? 0 : @resource[:timeout].to_i
    output = nil
    status = nil

    begin
      Timeout::timeout(timeout) do
        output, status = Puppet::Util::SUIDManager.run_and_capture(command, user, group)
        debug output if status.exitstatus == 0
        debug "Exit status = #{status.exitstatus}"
      end
    rescue Timeout::Error
      self.fail("Command timed out, increase timeout parameter if needed: #{command}")
    end

    if (status.exitstatus == 1) && (output == '')
      self.fail("mvn returned #{status.exitstatus}: Is Maven installed?")
    end
    unless status.exitstatus == 0
      self.fail("#{command} returned #{status.exitstatus}: #{output}")
    end
  end

  def destroy
    # no going back
    # FileUtils.rm @resource[:dest]
    raise NotImplementedError
  end

  def exists?
    # we could check if the file exists in the local repo but Buildr will do that before attempting to download it
    return File.exists?(@resource[:name])
  end
end
