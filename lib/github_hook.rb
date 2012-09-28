require 'sinatra/base'
require 'time'

# this is a hook to auto load and reset when new posts are pushed
# the reset! command is a sinatra special that resets & reloads
# this way routes aren't messed up, etc.
# 
# the hook responds to /update requests
# 
# autopull is helping us avoid pushing/pulling in development

class GithubHook < Sinatra::Base
  def self.parse_git
    #Parse hash and date from the git log command
    sha1, date = `git log HEAD~1..HEAD --pretty=format:%h^%ci`.strip.split('^')
    set :commit_hash, sha1
    set :commit_date, Time.parse(date)
  end
  
  set(:autopull) { production? }
  parse_git

  # set the cache to public for performance and allow revalidating
  # all of this takes place with the following header file settings::w
  before do
    cache_control :public, :must_revalidate
    etag settings.commit_hash
    last_modified settings.commit_date
  end

  post '/update' do
    settings.parse_git

    app.settings.reset!
    load app.settings.app_file

    content_type :txt
    if settings.autopull?
      # pipe stderr to sdout to make sure we display it all
      `git pull 2>&1`
    else
      "ok"
    end
  end
end
