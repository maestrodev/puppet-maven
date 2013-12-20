require 'spec_helper'

describe "maven::environment" do
  let(:title) { 'environment' }
  let(:params) { {
      :user => "u",
  } }

  expected_filename = '/home/u/.mavenrc'
  it { should contain_file(expected_filename).with_owner('u') }

  it { should contain_file(expected_filename).with_content(read_file("default-mavenrc")) }

  context "provide options for mavenrc" do
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
