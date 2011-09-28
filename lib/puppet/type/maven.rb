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
  newparam(:repos) do
    desc "Repositories to use for artifact downloading. Defaults to http://repo1.maven.apache.org/maven2"
  end

  validate do
    has_id = !self[:id].nil?
    self.fail "You must specify the id parameter" if !has_id
  end

end
