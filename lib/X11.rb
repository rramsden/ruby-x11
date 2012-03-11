require 'socket'
require 'active_support'
require 'hexdump'
require 'X11/protocol'
require 'X11/auth'
require 'X11/display'

module X11
  # Return a format string, suitable for pack(), for a string padded to a multiple
  # of 4 bytes. For instance, C<pack(padded('Hello'), 'Hello')> gives
  # C<"Hello\0\0\0">.
  def self.pad(x);  x + "\0"*(-x.length & 3); end

  class X11Error < StandardError; end
  class X11Exception < RuntimeException; end
end
