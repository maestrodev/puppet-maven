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

define maven::install_gem ($version = '') {
  exec { "gem ${name} ${version}":
    path        => '/usr/bin:/opt/ruby/bin',
    environment => "JAVA_HOME=${maven::java_home}",
    command     => "gem install ${name} --version ${version} --no-rdoc --no-ri",
    unless      => "gem query -i --name-matches ${name} --version ${version}",
    logoutput   => true,
  }
}
