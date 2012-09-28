require 'sinatra/base'
require 'github_hook'
require 'ostruct'
require 'time'
require 'yaml'

class Blog < Sinatra::Base
  use GithubHook

  # Making Relative Paths:
  #
  # __FILE__ shows the currently executed ruby source file 
  # relative to the execution directory.
  # 
  # File.expand_path converts a pathname to an absolute one
  # in this case using __File__ as a starting directory.
  #
  # They are both part of the Ruby API
  set :root, File.expand_path('../../', __FILE__)
  set :articles, []

  # loop through all article files
  Dir.glob "#{root}/articles/*.md" do |file|
    # parse meta data and content from file
    meta, content       = File.read(file).split("\n\n", 2)
    # generate a metadata object
    article             = OpenStruct.new YAML.load(meta)
    # convert the date to a time object
    article.date        = Time.parse article.date.to_s
    # add the content
    article.content     = content
    # generate a slug for the URL
    article.slug        = File.basename(file, '.md')
    # set up the route
    get "/#{article.slug}" do
      erb :post, :locals => { :article => article }
    end

    # add article to list of articles
    articles << article
  end
  
  # sort articles by date, display new articles first
  articles.sort_by! { |article| article.date }
  articles.reverse!

  get '/' do
    erb :index
  end
end
