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
define maven::maven( $version = '2.2.1',
	$binary = undef,
	$installation_dir='/opt',
	$default_mvn = true,
  	$repo = {
   	 #url      => 'http://repo1.maven.org/maven2',
   	 #username => '',
   	 #password => '',
  	} ) {

  

  # we could use puppet-stdlib function !empty(repo) but avoiding adding a new
  # dependency for now
  
	case $binary {
  		undef : {
  			$local_file = "/tmp/apache-maven-${version}-bin.tar.gz"
  			if "x${repo['url']}x" != 'xx' {
			    wget::authfetch { "fetch-maven-$version":
			      source      => "${repo['url']}/org/apache/maven/apache-maven/$version/apache-maven-${version}-bin.tar.gz",
			      destination => $local_file,
			      user        => $repo['username'],
			      password    => $repo['password'],
			      before      => Exec["${local_file}_extract"],
			    }
			} else {
	  			## undef=default value >> DEFAULT BEHAVIOUR: download the maven binary from apache.org 
			    wget::fetch { "fetch-maven-$version":
			      source      => "http://archive.apache.org/dist/maven/binaries/apache-maven-${version}-bin.tar.gz",
			      destination => $local_file,
			      before      => Exec["${local_file}_extract"],
			    }
		    }	    
	    }    
	    default : {
	    	$binary_name_segments = split ($binary, '[:]')
	    	
	    	$binary_name_filename = split ($binary, '[/]')
	    	$file_name = last_element($binary_name_filename)
	    	$local_file="/tmp/$file_name"
	    	case $binary_name_segments[0] {
	    		'http','https': {
	    			wget::fetch { "fetch-maven-$file_name":
				      source      => "$binary",
				      destination => $local_file,
				      before      => Exec["${local_file}_extract"],
				    }
	    		}
	    		default: {
	    			## file is delivered through puppet from puppetmaster to the puppet agent's tmp directory
	    			file { "$local_file":
	    				ensure => present,
	    				source => "$binary",
	    				before      => Exec["${local_file}_extract"],
	    			}
	    		}
	    	}
	    	
	}
    
  }
  
  archmngt::extract { "maven_$local_file" :
  	archive_file => "$local_file",
	target_dir => "$installation_dir",
	overwrite => true,
  }
  if $default_mvn { 
	  file { '/usr/bin/mvn':
	    ensure => link,
	    target => "$installation_dir/apache-maven-${version}/bin/mvn",
	    require => Exec["${local_file}_extract"],
	  }
	  file { '/usr/local/bin/mvn':
	    ensure  => absent,
	    require => Exec["${local_file}_extract"],
	  }
  }  
}
