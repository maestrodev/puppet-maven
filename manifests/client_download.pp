define maven::client_download (	
	$tmp_dir = "${maven::params::client_tmp_dir}",
	$localrepo_dir = "${maven::params::client_localrepo_dir}",
	$enc_master_password, $username, $enc_password, $server_url,
	$mvn_binary = 'http://jira.codehaus.org/secure/attachment/62786/apache-maven-3.0.4-ssec-bin.tar.gz',
	$mvn_install_dir_name = 'apache-maven-3.0.4',
	$gav_group, $gav_artifact, $gav_version="${maven::params::client_latest_version_tag}", $gav_type='', $gav_classifier='',
	$target_dir, $target_filename = undef	
){
  	$download_id = "$gav_group.$gav_artifact.$gav_version.$gav_classifier"
  	$download_exec_name = "mvn_client_download_${download_id}"
  	$ssec_file = "settings-security-$download_id.xml"
	$s_file = "settings-$download_id.xml"
	
	maven::settingssecurity { "maven_ssec_$download_id" :
	  enc_master_password => "$enc_master_password",
	  target_directory => "$tmp_dir",
	  target_filename => "$ssec_file",
	  require => File["$tmp_dir"],
	  notify => Exec["$maven::params::cleanup_client"],
	  before => Exec["$download_exec_name"],
	}	
	
	$download_server_id = "download_repo"
	$username_is_defined = ($username != undef)	
	if $username_is_defined {
		$auth_to_repo = { 
			id => "$download_server_id",
			username => "$username",
    		password => "$enc_password",
		}		 
	} else {
		$auth_to_repo = undef
	}
	
	$central = {
		id => "$download_server_id",
		url => "$server_url",
		mirrorof => "central",
	}	
	$mirrors = [$central]
	
	maven::settings { "maven_s_$download_id" :	  
	  target_directory => "$tmp_dir",
	  target_filename => "$s_file",
	  local_repo => "$localrepo_dir",
	  servers => [$auth_to_repo],
	  mirrors => $mirrors,
	  require => File["$tmp_dir"],
	  notify => Exec["$maven::params::cleanup_client"],
	  before => Exec["$download_exec_name"],
	}	
	
	$mvn_installation = "$tmp_dir/mvn_${download_id}"
	notice("install maven for download client to : $mvn_installation")
	file { "$mvn_installation":
		ensure => directory,
		mode => 0777,
		before => Exec["$download_exec_name"],
	}
	
	maven::maven { "maven_client_download_$download_id" :
		binary => "$mvn_binary",
		installation_dir => "$mvn_installation",
		default_mvn => false,
		require => File["$mvn_installation"],		
		before => Exec["$download_exec_name"],
	}
	
	$mvncmd = "$mvn_installation/$mvn_install_dir_name/bin/mvn"
			
	$gav_type_unset = ($gav_type=='')
	$type_suffix = $gav_type_unset ? {
		true=>'jar',
		default => ":$gav_type"
	}
		
	$gav_classifier_unset = ($gav_classifier=='')
	$classifier_suffix = $gav_classifier_unset ? {
		true=>'',
		default => ":$gav_classifier"
	}	
		
	$gav_id="$gav_group:$gav_artifact:$gav_version$type_suffix$classifier_suffix"
	
	if $target_filename == undef {
		$type_fsuffix = $gav_type_unset ? {
			true=>'.jar',
			default => ".$gav_type"
		}	
		$classifier_fsuffix = $gav_classifier_unset ? {
			true=>'',
			default => "-$gav_classifier"
		}
		$real_target_filename="${gav_artifact}-${gav_version}${classifier_fsuffix}${type_fsuffix}"
	} else {
		$real_target_filename=$target_filename
	}
	
	exec { "$download_exec_name": 
		command => "$mvncmd -s $tmp_dir/$s_file -ssec $tmp_dir/$ssec_file org.apache.maven.plugins:maven-dependency-plugin:2.4:get -Dartifact=$gav_id -DremoteRepositories=${download_server_id}::::$server_url -Ddest=$target_dir/$real_target_filename",
		path => ['/bin','/usr/bin'],
		notify => Exec["$maven::params::cleanup_client"],		
	} 
}	

