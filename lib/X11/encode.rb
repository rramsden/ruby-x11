# This module is used for encoding Ruby Objects to binary
# data. The types Int8, Int16, etc. are data-types defined
# in the X11 protocol. We wrap each data-type in a lambda expression
# which gets evaluated when a packet is created.
#
# EXAMPLE:
#   Int8.call(255)        => "\xFF"
#   String8.call("hello") => "hello"

module X11
  module Encode

    # List.of(Foo)
    # In this document the List.of notation strictly means some number of
    # repetitions of the FOO encoding; the actual length of the list is encoded
    # elsewhere

    class List
      class << self
        def of(type)
          lambda do |data|
            # X11 has other List.of(Foo) for different data types right now
            # will just throw an error until we've implemented them all.
            throw "dont know how to handle this yet"
          end
        end
      end
    end

    # Takes an object and uses Array#pack to
    # convert it into binary data
    def self.pack(a)
      lambda {|value| [value].pack(a)}
    end

    # X11 Protocol requires us to pad strings to a multiple of 4 bytes
    # For instance, C<pack(padded('Hello'), 'Hello')> gives C<"Hello\0\0\0">.
    def self.pad(x);  x + "\0"*(-x.length & 3); end

    # Primitive Types
    Int8      = pack("c")
    Int16     = pack("s")
    Int32     = pack("l")
    Uint8     = pack("C")
    Uint16    = pack("S")
    Uint32    = pack("L")

    # LISTofFOO
    String8   = lambda{|x| self.pad(x)} # equivalent to List.of(Uint8) /w padding
  end
end
