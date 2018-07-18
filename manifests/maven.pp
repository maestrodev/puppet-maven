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
# Requires:
#   Java package installed.
#
# Sample Usage:
#   class {'maven::maven':
#     version => "3.2.5",
#   }
#
class maven::maven(
  $version = '3.2.5',
  $basedir = '/opt',
  $repo = {
    #url      => 'http://repo1.maven.org/maven2',
    #username => '',
    #password => '',
  } ) {

  $archive = "/tmp/apache-maven-${version}-bin.tar.gz"

  # prior to puppet 3.5.0, defined() couldn't test if a variable was defined.
  # strict_variables wasn't added until 3.5.0, so this should be fine.
  if $::puppetversion and versioncmp($::puppetversion, '3.5.0') < 0 {
    $xfacts = {
      'maven_version' => $::maven_version,
    }
  } else {
    # Strict variables facts lookup compatibility
    $xfacts = {
      'maven_version' => defined('$maven_version') ? {
        true    => $::maven_version,
        default => undef,
      }
    }
  }

  # Avoid redownloading when tmp tar.gz is deleted
  if $xfacts['maven_version'] != $version {

    # we could use puppet-stdlib function !empty(repo) but avoiding adding a new
    # dependency for now
    if "x${repo['url']}x" != 'xx' {
      wget::authfetch { 'fetch-maven':
        source      => "${repo['url']}/org/apache/maven/apache-maven/${version}/apache-maven-${version}-bin.tar.gz",
        destination => $archive,
        user        => $repo['username'],
        password    => $repo['password'],
        before      => Exec['maven-untar'],
      }
    } else {
      wget::fetch { 'fetch-maven':
        source      => "http://archive.apache.org/dist/maven/maven-3/${version}/binaries/apache-maven-${version}-bin.tar.gz",
        destination => $archive,
        before      => Exec['maven-untar'],
      }
    }
    exec { 'maven-untar':
      command => "tar xf /tmp/apache-maven-${version}-bin.tar.gz",
      cwd     => $basedir,
      creates => "${basedir}/apache-maven-${version}",
      path    => ['/bin','/usr/bin'],
    }

    file { '/usr/bin/mvn':
      ensure  => link,
      target  => "${basedir}/apache-maven-${version}/bin/mvn",
      require => Exec['maven-untar'],
    }
    -> file { '/usr/local/bin/mvn':
      ensure  => absent,
    }
  }
}
