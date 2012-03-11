# This module is used for encoding Ruby Objects to binary
# data. The types Int8, Int16, etc. are data-types defined
# in the X11 protocol. We wrap each data-type in a lambda expression
# which gets evaluated when a packet is created.
#
# EXAMPLE:
#   Int8.call(255)        => "\xFF"
#   String8.call("hello") => "hxello\u0000\u0000\u0000"

module X11
  module Encode
    # Takes an object and uses Array#pack to
    # convert it into binary data
    def self.pack(a)
      lambda {|value| [value].pack(a)}
    end

    # X11 Protocol requires us to pad strings to a multiple of 4 bytes
    # For instance, C<pack(padded('Hello'), 'Hello')> gives C<"Hello\0\0\0">.
    def self.pad(x);  x + "\0"*(-x.length & 3); end

    Int8      = pack("c")
    Int16     = pack("s")
    Int32     = pack("l")
    Uint8     = pack("C")
    Uint16    = pack("S")
    Uint32    = pack("L")
    String8   = lambda {|a| pad(a)}
  end
end
