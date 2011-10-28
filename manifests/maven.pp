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
class maven::maven( $version = "2.2.1" ) {

  wget::fetch { "fetch-maven":
    source => "http://archive.apache.org/dist/maven/binaries/apache-maven-${version}-bin.tar.gz",
    destination => "/tmp/apache-maven-${version}-bin.tar.gz",
  } ->
  exec { "maven-untar":
    command => "tar xf /tmp/apache-maven-${version}-bin.tar.gz",
    cwd => "/opt",
    creates => "/opt/apache-maven-${version}",
    path => ["/bin"]
  } ->
  file { "/usr/bin/mvn":
    ensure => link,
    target => "/opt/apache-maven-${version}/bin/mvn",
  }
}
