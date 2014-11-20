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

# Class: maven::maven
#
# A puppet recipe to install Apache Maven
#
# Parameters:
#   - $version:
#         Maven version.
#
#   - $manage_symlink:
#         If symlink should be managed
#
#   - $system_package:
#         Name of system package to install. False to install with wget / tar
#
#   - $symlink_target:
#         Optional alternative path to mvn cmd
#
# Requires:
#   Java package installed.
#
# Sample Usage:
#   class {'maven::maven':
#     version => "3.0.5",
#   }
#
class maven::maven(
  $version = '3.0.5',
  $manage_symlink = true,
  $system_package = false,
  $symlink_target = undef,
  $repo = {
    #url      => 'http://repo1.maven.org/maven2',
    #username => '',
    #password => '',
  } ) {

  if $system_package {
    package { $system_package:
      ensure  => $version
    } ->
    File <| title == '/usr/bin/mvn' |>
  } else {
    if "x${repo['url']}x" != 'xx' {
      $repo_url = "${repo['url']}/org/apache/maven/apache-maven/${version}/apache-maven-${version}-bin.tar.gz"
    } else {
      $repo_url = "http://archive.apache.org/dist/maven/binaries/apache-maven-${version}-bin.tar.gz"
    }
    if !defined(Package['wget']) {
      package { 'wget':
        ensure  => present
      }
    }
    if "x${repo['username']}x" != 'xx' and "x${repo['password']}x" != 'xx' {
      $wget_login = "--user=\"${repo['username']}\" --password=\"${repo['password']}\" "
    } else {
      $wget_login = ''
    }
    exec { 'install_maven':
      command => "wget -O - ${wget_login}${repo_url} | tar zxf -",
      cwd     => '/opt',
      path    => ['/usr/local/bin', '/usr/bin', '/bin'],
      creates => "/opt/apache-maven-${version}",
      require => Package['wget']
    } ->
    File <| title == '/usr/bin/mvn' |>
  }

  if $manage_symlink {
    $symlink_target_real = $symlink_target ? {
      undef   => "/opt/apache-maven-${version}/bin/mvn",
      default => $symlink_target
    }
    file { '/usr/bin/mvn':
      ensure  => link,
      target  => $symlink_target_real
    } ->
    file { '/usr/local/bin/mvn':
      ensure  => absent,
    }
  }

}
