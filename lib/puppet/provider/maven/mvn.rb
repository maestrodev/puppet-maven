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
require 'tempfile'

Puppet::Type.type(:maven).provide(:mvn) do
  desc "Maven download using mvn command line."
  include Puppet::Util::Execution

  def ensure
    if !exists?
      value = :absent
    elsif @resource[:ensure] == :latest && !outdated?
      value =  :latest
    else
      value = :present
      #value = Digest::MD5.file(@resource[:name]).hexdigest
    end
    debug "#{@resource[:name]} ensure #{value}"
    value
  end

  def ensure=(value)
    debug "#{@resource[:name]} ensure = #{value}"
    ([:present, :latest] & [value]).any? ? create(value) : destroy
  end

  private
  [:artifactid,
  :version,
  :packaging,
  :classifier,
  :options,
  :user,
  :group,
  :groupid,
  :repoid].each { |m| define_method(m) { @resource[m] } }

  def full_id
    @resource[:id]
  end

  def plugin_version
    @resource[:pluginversion].nil? ? "2.4" : @resource[:pluginversion]
  end

  def repos
    repos = @resource[:repos]
    if repos.nil? || repos.empty?
      ["http://repo1.maven.apache.org/maven2"]
    elsif !repos.kind_of?(Array)
      [repos]
    else
      repos
    end
  end

  # is it a version that automatically updates? (SNAPSHOT, LATEST, RELEASE)
  def updatable?
    if full_id.nil?
      ver = version
    else
      ver = full_id.split(':')[2]
    end

    value = ver =~ /SNAPSHOT$/ || ver == 'LATEST' || ver == 'RELEASE'
    debug "#{@resource[:name]} updatable? #{value}"
    value
  end

  def inlocalrepo? tempfile
    # try an "offline" maven download
    value = download tempfile, false, true
    debug "#{@resource[:name]} in local repo? #{value}"
    value
  end

  def create(value)
    download name, value == :latest
  end

  def download(dest, latest, offline = false)
    # Remote repositories to use
    debug "Repositories to use: #{repos.join(', ')}"

    # Download the artifact fom the repo
    command_string = "-Dartifact=#{full_id}"
    msg = full_id
    if (full_id.nil?)
      command_string = "-DgroupId=#{groupid} -DartifactId=#{artifactid} -Dversion=#{version} "
      command_string = command_string + "-Dpackaging=#{packaging} " unless packaging.nil?
      command_string = command_string + "-Dclassifier=#{classifier}" unless classifier.nil?
      msg = "#{groupid}:#{artifactid}:#{version}:" + (packaging.nil? ? "" : packaging) + ":" + (classifier.nil? ? "" : classifier)
    end

    if offline
      command_string = command_string + " -o "
    else
      command_string = command_string + " -U " if updatable? && latest
    end

    # set the repoId if specified
    command_string = command_string + " -DrepoId=#{repoid}" unless repoid.nil?

    if offline
      debug "mvn copying repo file #{msg} to #{dest} from local repo"
    else
      debug "mvn downloading (if needed) repo file #{msg} to #{dest} from #{repos.join(', ')}"
    end

    command = ["mvn org.apache.maven.plugins:maven-dependency-plugin:#{plugin_version}:get #{command_string} -DremoteRepositories=#{repos.join(',')} -Ddest=#{dest} -Dtransitive=false -Ppuppet-maven #{options}"]

    timeout = @resource[:timeout].nil? ? 0 : @resource[:timeout].to_i
    output = nil
    status = nil

    begin
      Timeout::timeout(timeout) do
        output = Puppet::Util::Execution.execute(command, {:uid => user, :gid => group})

        debug output if output.exitstatus == 0
        debug "Exit status = #{output.exitstatus}"
      end
    rescue Timeout::Error
      self.fail("Command timed out, increase timeout parameter if needed: #{command}")
    end

    if (output.exitstatus == 1) && (output == '')
      self.fail("mvn returned #{output.exitstatus}: Is Maven installed?")
    end

    # if we are offline, we check by this if the file is yet downloaded
    if output.exitstatus != 0 && !offline
      self.fail("#{command} returned #{output.exitstatus}: #{output}")
    end

    output.exitstatus == 0
  end

  def destroy
    # no going back
    # FileUtils.rm @resource[:dest]
    raise NotImplementedError
  end

  def exists?
    return File.exists?(@resource[:name])
  end

  def outdated?
    tempfile = Tempfile.new 'mvn'
    FileUtils.chown(user, group, tempfile.path)
    if updatable?
      download tempfile.path, true
      !FileUtils.compare_file @resource[:name], tempfile.path
    else
      if inlocalrepo? tempfile.path
        !FileUtils.compare_file @resource[:name], tempfile.path
      else
        true
      end
    end
  end
end
