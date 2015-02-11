# encoding: UTF-8

require 'json'
require_relative 'support/shell'

describe "integration" do
  BUILD_DIR = File.join(Dir.pwd, 'spec', 'site')
  JSON_PATH = File.join(BUILD_DIR, '_site', 'api', 'v1', 'pages.json')

  def read_json(path)
    contents = File.read(path)
    JSON.parse(contents)
  end

  def entries_data
    json = read_json(JSON_PATH)
    json['entries']
  end

  def page_data(url)
    entries_data.find{|page| page['url'] == url }
  end

  def homepage_data
    page_data('/')
  end

  before(:context) do
    # http://bundler.io/man/bundle-exec.1.html#Shelling-out
    Bundler.with_clean_env do
      Dir.chdir(BUILD_DIR) do
        run_cmd('bundle')
        run_cmd('bundle exec jekyll build')
      end
    end
  end

  it "generates the JSON file" do
    expect(File.exist?(JSON_PATH)).to be_truthy
  end

  it "includes an entry for every page" do
    urls = entries_data.map{|page| page['url'] }
    expect(urls).to eq(%w(
      /about/
      /index.html
      /unicode.html
    ))
  end

  it "removes liquid tags" do
    entries_data.each do |page|
      expect(page['body']).to_not include('{%')
      expect(page['body']).to_not include('{{')
    end
  end

  it "removes HTML tags" do
    entries_data.each do |page|
      expect(page['body']).to_not include('<')
    end
  end

  it "condenses the content" do
    entries_data.each do |page|
      expect(page['body']).to_not match(/\s{2,}/m)
    end
  end

  it "handles unicode" do
    page = page_data('/unicode.html')
    expect(page['body']).to eq("”Handle the curly quotes!” they said.")
  end
end
