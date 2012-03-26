$repo1 = {
  id       => 'myrepo',
  username => 'myuser',
  password => 'mypassword',
  url      => 'http://repo.acme.com',
}

#class { 'maven::maven':
#  version => '2.2.1',
#} ->
#maven::settings { 'root' :
#  servers => [$repo1],
#}

maven { '/tmp/maven-core-2.2.1.jar':
  id     => 'org.apache.maven:maven-core:2.2.1:jar',
  #repos => ['file:///Users/csanchez/.m2/repository'],
  repos  => ['central::default::http://repo1.maven.apache.org/maven2','http://mirrors.ibiblio.org/pub/mirrors/maven2'],
}
maven { '/tmp/maven-core-2.2.1-sources.jar':
  groupid    => 'org.apache.maven',
  artifactid => 'maven-core',
  version    => '2.2.1',
  classifier => 'sources',
}
