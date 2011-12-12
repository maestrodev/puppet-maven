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

require 'puppet/type'

Puppet::Type.newtype(:maven) do
  require 'timeout'

  @doc = "Maven repository files."

  ensurable do
    self.defaultvalues
    defaultto :present
  end

  # required or puppet will fail with one of these errors
  # err: Could not render to pson: undefined method `merge' for []:Array
  # Could not evaluate: No ability to determine if maven exists
  def self.title_patterns
    [ [ /^(.*?)\/*\Z/m, [ [ :path, lambda{|x| x} ] ] ] ]
  end

  newparam(:path) do
    desc "The destination path of the downloaded file."
    isnamevar
  end

  newparam(:id) do
    desc "The Maven repository id, ie. 'org.apache.maven:maven-core:jar:2.2.1',
      'org.apache.maven:maven-core:jar:sources:2.2.1'"
  end
  newparam(:groupid) do
    desc "The Maven arifact group id, ie. 'org.apache.maven'"
  end
  newparam(:artifactid) do
    desc "The Maven artifact id, ie. 'maven-core'"
  end
  newparam(:version) do
    desc "The Maven artifact version, ie. '2.2.1'"
  end
  newparam(:packaging) do
    desc "The Maven artifact packaging, ie. 'jar'"
  end
  newparam(:classifier) do
    desc "The Maven artifact classifier, ie. 'sources'"
  end

  newparam(:repoid) do
    desc "Id of the repository to use. Useful for mirroring, authentication,..."
  end
  newparam(:repos) do
    desc "Repositories to use for artifact downloading. Defaults to http://repo1.maven.apache.org/maven2"
  end
  newparam(:timeout) do
    desc "Download timeout."
  end
  newparam(:pluginversion) do
    desc "Version of the dependency plugin to use."
  end
  newparam(:options) do
    desc "Other options to pass to mvn."
  end

  newparam(:user) do
    desc "User to run Maven as. Useful to share a local repo and settings.xml. Defaults to root."
  end
  newparam(:group) do
    desc "Group to run Maven as. Defaults to root."
  end

  validate do
    full_id = self[:id]
    groupid = self[:groupid]
    artifactid = self[:artifactid]
    version = self[:version]
    packaging = self[:packaging]
    classifier = self[:classifier]

    using_detailed_parameters = !groupid.nil? || !artifactid.nil? || !version.nil? || !packaging.nil? || !classifier.nil?
    if (!full_id.nil? && using_detailed_parameters)
      self.fail "Can't define id and other groupid, artifactid, version, packaging, classifier parameters at the same time"
    end
    if (using_detailed_parameters && (groupid.nil? || artifactid.nil? || version.nil?))
      self.fail "Missing required groupid, artifactid or version parameters"
    end

  end

end
