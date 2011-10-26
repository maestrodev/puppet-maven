#class { "maven": }

maven { "/tmp/maven-core-2.2.1.jar":
  id => "org.apache.maven:maven-core:2.2.1:jar",
  repoid => "maestro",
  #repos => ["file:///Users/csanchez/.m2/repository"],
  #repos => ["http://repo1.maven.apache.org/maven2","http://mirrors.ibiblio.org/pub/mirrors/maven2"],
  provider => "mvn",
}
maven { "/tmp/maven-core-2.2.1-sources.jar":
  groupid => "org.apache.maven",
  artifactid => "maven-core",
  version => "2.2.1",
  classifier => "sources",
  repoid => "maestro",
  provider => "mvn",
}
