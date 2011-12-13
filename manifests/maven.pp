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

# Class: maven
# 
# A puppet recipe to install Apache Maven
#
class maven::maven( $version = "2.2.1",
  $repo = {
    #url => "http://repo1.maven.org/maven2",
    #username => "",
    #password => "",
  }, $user = "root", $home = "/root", $user_system = true,
  $maven_opts = "",
  $maven_path_aditions = "" ) {

  $archive = "/tmp/apache-maven-${version}-bin.tar.gz"

  if !defined(User[$user]) {
    user { $user:
      ensure     => present,
      home       => $home,
      managehome => true,
      shell      => "/bin/bash",
      system     => $user_system,
    }
  }

  # we could use puppet-stdlib function !empty(repo) but avoiding adding a new dependency for now
  if "x${repo['url']}x" != "xx" {
    wget::authfetch { "fetch-maven":
      source => "${repo['url']}/org/apache/maven/apache-maven/$version/apache-maven-${version}-bin.tar.gz",
      destination => $archive,
      user => $repo['username'],
      password => $repo['password'],
      before => Exec["maven-untar"],
    }
  } else {
    wget::fetch { "fetch-maven":
      source => "http://archive.apache.org/dist/maven/binaries/apache-maven-${version}-bin.tar.gz",
      destination => $archive,
      before => Exec["maven-untar"],
    }
  }
  exec { "maven-untar":
    command => "tar xf /tmp/apache-maven-${version}-bin.tar.gz",
    cwd => "/opt",
    creates => "/opt/apache-maven-${version}",
    path => ["/bin"],
  } ->
  file { "/usr/bin/mvn":
    ensure => link,
    target => "/opt/apache-maven-${version}/bin/mvn",
  }
  file { "/usr/local/bin/mvn":
    ensure => absent,
    require => Exec["maven-untar"],
  }
  file { "$home/.mavenrc":
    mode => "0600",
    owner => $user,
    content => template("maven/mavenrc.erb"),
    require =>  User[$user],
  }
}
