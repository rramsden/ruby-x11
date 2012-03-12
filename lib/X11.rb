require 'socket'
require 'active_support'
require 'hexdump'
require 'X11/protocol'
require 'X11/auth'
require 'X11/display'
require 'X11/encode'
require 'X11/packet'

module X11
  class X11Error < StandardError; end
  class X11Exception < RuntimeException; end
end
