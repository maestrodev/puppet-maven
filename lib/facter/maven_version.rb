Facter.add("maven_version") do
  setcode do
    version = Facter::Util::Resolution.exec('mvn --version')
    version.chomp.split("\n")[0].split(" ")[2] if version
  end
end
