class maven::params {
	$tmp_dir = '/tmp/mvnrepo'
	$version = latest
	
	## client default vars
	$client_tmp_dir ="$tmp_dir/client"
	$client_localrepo_dir ="$tmp_dir/client/repository"
	$client_settings = "$client_tmp_dir/settings.xml" 
	$client_settings_security = "$client_tmp_dir/settings-security.xml"
	$client_latest_version_tag='LATEST'
	
	$cleanup_client = "mvn_tmp_client_cleanup"
}