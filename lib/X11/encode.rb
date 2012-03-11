module X11
  # used to encode plain data into
  # binary data which the X11 protocol can read
  module Encode
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
