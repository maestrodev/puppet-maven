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
puppet module install pkg/maestrodev-maven-0.0.1.tar.gz
```

Of course, you can also clone the repository straight into `/etc/puppet/modules/maven` as well.

If you are developing the module, it can be built using `rake`:

```sh
gem install bundler
bundle
rake
```

In this case other required gems are automatically installed, and the package resides in the same location for publishing to your Puppet master.

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
    version => "2.2.1",
    packaging => "jar",
    classifier => "sources",
    repos => ["id::layout::http://repo.acme.com","http://repo2.acme.com"],
  }
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

  # Install Maven
  class { "maven::maven":
    version => "2.2.1", # version to install
    # you can get Maven tarball from a Maven repository instead than from Apache servers, optionally with a user/password
    repo => {
      #url => "http://repo.maven.apache.org/maven2",
      #username => "",
      #password => "",
    },
    user                 => "maven",  # if you want to run it as a different user (defaults to root), will create it if not defined
    user_system          => true,    # make the user a system user
    maven_opts           => "",      # anything to add to MAVEN_OPTS in ~/.mavenrc
    maven_path_additions => "",      # anything to add to the PATH in ~/.mavenrc
  } ->

  # Create a settings.xml with the repo credentials
  maven::settings { 'maven-user-settings' :
    mirrors => [$central], # mirrors entry in settings.xml, uses id, url, mirrorof from the hash passed
    servers => [$central], # servers entry in settings.xml, uses id, username, password from the hash passed
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
  maven { "/tmp/maven-core-2.2.1.jar":
    id => "org.apache.maven:maven-core:2.2.1:jar",
    repos => ["central::default::http://repo.maven.apache.org/maven2","http://mirrors.ibiblio.org/pub/mirrors/maven2"],
  }

  maven { "/tmp/maven-core-2.2.1-sources.jar":
    groupid    => "org.apache.maven",
    artifactid => "maven-core",
    version    => "2.2.1",
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

