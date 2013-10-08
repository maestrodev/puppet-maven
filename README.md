Puppet-Maven
============

A Puppet recipe for Apache Maven, to download artifacts from a Maven repository

Uses [Apache Maven](http://maven.apache.org) command line to download the artifacts.

Building and Installing the Module
----------------------------------

To build the module for installing in your Puppet master:

```sh
gem install puppet-module
git clone git://github.com/maestrodev/puppet-maven.git
cd puppet-maven
puppet module build
puppet module install pkg/maestrodev-maven-1.0.1.tar.gz
```

Of course, you can also clone the repository straight into `/etc/puppet/modules/maven` as well.

Developing and Testing the Module
---------------------------------

If you are developing the module, it can be built using `rake`:

```sh
gem install bundler
bundle
rake spec
rake spec:system
```

Usage
-----

```puppet
  maven { "/tmp/myfile":
    id => "groupId:artifactId:version:packaging:classifier",
    repos => ["id::layout::http://repo.acme.com","http://repo2.acme.com"],
  }
```

or

```puppet
  maven { "/tmp/myfile":
    groupid => "org.apache.maven",
    artifactid => "maven-core",
    version => "3.0.5",
    packaging => "jar",
    classifier => "sources",
    repos => ["id::layout::http://repo.acme.com","http://repo2.acme.com"],
  }
```

### ensure

`ensure` may be one of two values:
* `present` (the default) -- the specified maven artifact is downloaded when no file exists
   at `path` (or `name` if no path is specified.)  This is probably makes
   sense when the specified maven artifact refers to a released (non-SNAPSHOT)
   artifact.
*  `latest` -- if value of version is `RELEASE`, `LATEST`, or a SNAPSHOT the repository
   is queried for an updated artifact.  If an updated artifact is found the file
   at `path` is replaced.

### MAVEN_OPTS Precedence

Values set in `maven_opts` will be _prepended_ to any existing
`MAVEN_OPTS` value. This ensures that those already specified will win over
those added in `mavenrc`.

If you would prefer these options to win, instead use:

```puppet
  maven_opts        => "",
  mavenrc_additions => 'MAVEN_OPTS="$MAVEN_OPTS -Xmx1024m"
```

Examples
--------

### Setup

```puppet
  $central = {
    id => "myrepo",
    username => "myuser",
    password => "mypassword",
    url => "http://repo.acme.com",
    mirrorof => "external:*",      # if you want to use the repo as a mirror, see maven::settings below
  }
  
  $proxy = {
    active => true, #Defaults to true
    protocol => 'http', #Defaults to 'http'
    host => 'http://proxy.acme.com',
    username => 'myuser', #Optional if proxy does not require
    password => 'mypassword', #Optional if proxy does not require
    nonProxyHosts => 'www.acme.com', #Optional, provides exceptions to the proxy
  }

  # Install Maven
  class { "maven::maven":
    version => "3.0.5", # version to install
    # you can get Maven tarball from a Maven repository instead than from Apache servers, optionally with a user/password
    repo => {
      #url => "http://repo.maven.apache.org/maven2",
      #username => "",
      #password => "",
    }
  } ->

  # Setup a .mavenrc file for the specified user
  maven::environment { 'maven-env' : 
      user => 'root',
      # anything to add to MAVEN_OPTS in ~/.mavenrc
      maven_opts => '-Xmx1384m',       # anything to add to MAVEN_OPTS in ~/.mavenrc
      maven_path_additions => "",      # anything to add to the PATH in ~/.mavenrc

  } ->

  # Create a settings.xml with the repo credentials
  maven::settings { 'maven-user-settings' :
    mirrors => [$central], # mirrors entry in settings.xml, uses id, url, mirrorof from the hash passed
    servers => [$central], # servers entry in settings.xml, uses id, username, password from the hash passed
    proxies => [$proxy], # proxies entry in settings.xml, active, protocol, host, username, password, nonProxyHosts
    user    => 'maven',
  }

  # defaults for all maven{} declarations
  Maven {
    user  => "maven", # you can make puppet run Maven as a specific user instead of root, useful to share Maven settings and local repository
    group => "maven", # you can make puppet run Maven as a specific group
    repos => "http://repo.maven.apache.org/maven2"
  }
```

Downloading artifacts
---------------------

```puppet
  maven { "/tmp/maven-core-3.0.5.jar":
    id => "org.apache.maven:maven-core:3.0.5:jar",
    repos => ["central::default::http://repo.maven.apache.org/maven2","http://mirrors.ibiblio.org/pub/mirrors/maven2"],
  }

  maven { "/tmp/maven-core-3.0.5-sources.jar":
    groupid    => "org.apache.maven",
    artifactid => "maven-core",
    version    => "3.0.5",
    classifier => "sources",
  }
```

Buildr version
--------------

Initially there was an [Apache Buildr](http://buildr.apache.org) version, but it required to have Buildr installed before running Puppet and you would need to [enable pluginsync](http://docs.puppetlabs.com/guides/plugins_in_modules.html#enabling-pluginsync)
in both master and clients.

License
-------
```
  Copyright 2011-2012 MaestroDev

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
```

Author
------

Carlos Sanchez <csanchez@maestrodev.com>
[MaestroDev](http://www.maestrodev.com)
2010-03-01

