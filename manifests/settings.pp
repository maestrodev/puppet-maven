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
define maven::settings( 
	$target_directory = undef, $target_filename= 'settings.xml', 
	$user = 'root',
  	$servers = [], $mirrors = [], $default_repo_config = {}, $properties = {}, $local_repo = '' 
) {

  if $target_directory == undef {
    $target_real = $user ? {
      'root'  => '/root/.m2',
      default => "/home/${user}/.m2"
    }
  }
  else {
    $target_real = $target_directory
  }

#  file { "${target_real}":
#    ensure => directory,
#    owner  => $user,
#    mode   => '0700',
#  } ->
## target directory creation should not be part of the definition
## otherwise you can't use the definition several times
  file { "${target_real}/${target_filename}":
    owner   => $user,
    mode    => '0600',
    content => template('maven/settings.xml.erb'),
    require => File["${target_real}"],
  }

}
