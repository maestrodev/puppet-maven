require 'spec_helper'

describe "maven::environment" do
  let(:title) { 'environment' }
  let(:params) { {
      :user => "u",
  } }

  let(:expected_filename) { '/home/u/.mavenrc' }

  context "default params", :compile do
    it { should contain_file(expected_filename).with_owner('u') }
    it { should contain_file(expected_filename).with_content(read_file("default-mavenrc")) }
  end

  context "provide options for mavenrc", :compile do
    let(:params) {{
        :user => "u",
        :maven_opts => "-Xmx256m",
        :maven_path_additions => "/usr/local/bin",
        :mavenrc_additions => "echo Hello World!"
    }}

    it { should contain_file(expected_filename).with_content(read_file("populated-mavenrc")) }
  end

end

def read_file(filename)
  IO.read(File.expand_path(filename, File.dirname(__FILE__)))
end
