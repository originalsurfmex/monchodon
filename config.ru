$LOAD_PATH.unshift 'lib'

# this is optional - implement HTTP cache as rack middleware
# this uses the caching of headers we specified in our helper
require 'rack/cache'
use Rack::Cache

require 'blog'
run Blog
