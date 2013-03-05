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
# A puppet recipe for Apache Maven, to download artifacts
# from a Maven repository
#
# It uses Apache Maven command line to download the artifacts.
#
# Parameters:
#   - $version:
#         Maven version.
#	-
#
# Requires:
#   Java package installed.
#
# Sample Usage:
#   class {'maven':
#     version => "2.2.1",
#   }
#
class maven (
	$install_managed = false,
	$install_package = true,
	$version = $maven::params::version
) inherits maven::params{
	notice('Installing Maven module pre-requisites') 
	
	if $install_package {
		case $install_managed {
			true : {
				class {
					'maven::managed' :
						version => $version,
				}
			}
			default : {
				## ensure backward compatibility of module
				$is_latest = ($version == latest)
				$concrete_version = $is_latest ? {
					true => '2.2.1',
					default => "$version",	
				}
				maven::maven { "maven_manually_$concrete_version" :
						version => "$concrete_version",
				}
			}
		}
	}
	
	## ensure that the standard tmp directory structure is present
	file { "$maven::params::tmp_dir":
		ensure => directory,
		mode => '0777',				
	}	
	file { "$maven::params::client_tmp_dir":
		ensure => directory,
		mode => '0777',		
		require => File["$maven::params::tmp_dir"],		
	}
	
	## this is only executed at the end of a puppet recipe if it has been notified
	## classes and definition, that cause a notification: maven::client::download
	exec { "$maven::params::cleanup_client":
		command => "rm -rf $maven::params::client_tmp_dir",
		path => ["/bin"],
		refreshonly => true,
	}
} 
