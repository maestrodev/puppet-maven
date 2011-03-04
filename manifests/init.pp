class maven {

  # we use buildr to download artifacts
  package { "buildr":
    ensure => "1.4.5",
    provider => gem
  }
}
