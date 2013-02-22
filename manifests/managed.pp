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
#     version => "2.2.1",
#   }
#
class maven::managed(
	$version = latest) 
{
	
	case $::operatingsystem {
		/(?i:Ubuntu|Debian|Mint)/ : {
			$mvn_package_name = 'maven'
		}
		/(?i:RedHat|Centos|OEL)/ : {
			$mvn_package_name = 'maven2'
			# TODO add package name case selection as soon as mvn3 is available in an rpm repo
		}
		default : {
			fail("operating system $::operatingsystem not yet supported by mvnrepo module")			
		}
	}
	$mvn_package_version = $version == latest ? {
		true => latest,
		default => "$version",
	}
	package {
		'maven' :
			name => "$::mvn_package_name",
			ensure => $::mvn_package_version,
	}	
}
