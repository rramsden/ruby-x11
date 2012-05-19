require 'rubygems'
require 'bundler'
Bundler.setup(:default, :development)

require 'minitest/spec'
require 'minitest/autorun'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'X11'
