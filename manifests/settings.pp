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

# Define: maven::settings
#
# A puppet recipe to set the contents of the settings.xml file
#
define maven::settings( $home = '/root', $user = 'root',
  $servers = [], $mirrors = [], $default_repo_config = {}, $properties = {}, $local_repo = '' ) {

  file { "${home}/.m2":
    ensure => directory,
    owner  => $user,
    mode   => '0700',
  } ->
  file { "${home}/.m2/settings.xml":
    owner   => $user,
    mode    => '0600',
    content => template('maven/settings.xml.erb'),
  }

}
