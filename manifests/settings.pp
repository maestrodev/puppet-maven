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
#
# servers => [{
#   id,
#   username,
#   password
# },...]
#
# mirrors => [{
#   id,
#   url,
#   mirrorOf
# },...]
#
# properties => {
#   key=>value
# }
#
# repos => [{
#   id,
#   name, #optional
#   url,
#   releases => {
#     key=>value
#   },
#   snapshots=> {
#     key=>value
#   }
# },...]
#
# # Provided for backwards compatibility
# # A shortcut to essentially add the central repo to the above list of repos.
# default_repo_config => {
#   url,
#   releases => {
#     key=>value
#   },
#   snapshots=> {
#     key=>value
#   }
# }
#
# proxies => [{
#   active, #optional, default to true
#   protocol, #optional, defaults to http
#   host,
#   port,
#   username,#optional
#   password, #optional
#   nonProxyHosts #optional
# },...]
define maven::settings( $home = undef, $user = 'root',
  $servers = [], $mirrors = [], $default_repo_config = undef, $repos = [],
  $properties = {}, $local_repo = '', $proxies=[]) {

  if $home == undef {
    $home_real = $user ? {
      'root'  => '/root',
      default => "/home/${user}"
    }
  }
  else {
    $home_real = $home
  }

  file { "${home_real}/.m2":
    ensure => directory,
    owner  => $user,
    mode   => '0700',
  } ->
  file { "${home_real}/.m2/settings.xml":
    owner   => $user,
    mode    => '0600',
    content => template('maven/settings.xml.erb'),
  }

}
