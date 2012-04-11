require "#{File.join(File.dirname(__FILE__),'..','spec_helper')}"

describe "maven::environment" do
  let(:title) { 'environment' }
  let(:params) { {
      :user => "u",
  } }

  expected_filename = '/home/u/.mavenrc'
  it { should contain_file(expected_filename).with_owner('u') }

  it 'should generate valid mavenrc' do
    content = catalogue.resource('file', expected_filename).send(:parameters)[:content]
    content.should == read_file("default-mavenrc")
  end

  context "provide options for mavenrc" do
    let(:params) {{
        :user => "u",
        :maven_opts => "-Xmx256m",
        :maven_path_additions => "/usr/local/bin",
        :mavenrc_additions => "echo Hello World!"
    }}

    it 'should generate valid mavenrc' do
      content = catalogue.resource('file', expected_filename).send(:parameters)[:content]
      content.should == read_file("populated-mavenrc")
    end

  end

end

def read_file(filename)
  IO.read(File.expand_path(filename, File.dirname(__FILE__)))
end
