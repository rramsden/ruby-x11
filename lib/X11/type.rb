# This module is used for encoding Ruby Objects to binary
# data. The types Int8, Int16, etc. are data-types defined
# in the X11 protocol. We wrap each data-type in a lambda expression
# which gets evaluated when a packet is created.

module X11
  module Type

    def self.define(type, directive, bytesize)
      eval %{
        class X11::Type::#{type}
          def self.pack(x)
            [x].pack(\"#{directive}\")
          end

          def self.unpack(x)
            x.unpack(\"#{directive}\").first
          end

          def self.size
            #{bytesize}
          end
        end
      }
    end

    # Primitive Types
    define "Int8", "c", 1
    define "Int16", "s", 2
    define "Int32", "l", 4
    define "Uint8", "C", 1
    define "Uint16", "S", 2
    define "Uint32", "L", 4

    KeyCode      = Uint8
    Signifigance = Uint8
    Bool         = Uint8

    Bitmask      = Uint32
    Window       = Uint32
    Pixmap       = Uint32
    Cursor       = Uint32
    Colornum     = Uint32
    Font         = Uint32
    Gcontext     = Uint32
    Colormap     = Uint32
    Drawable     = Uint32
    Fontable     = Uint32
    Atom         = Uint32
    VisualID     = Uint32
    EventMask    = Uint32

    # Strings are "Special" in X11 they are a list
    # data type but their padded
    class String8
      def self.pack(x)
        x + "\x00"*(-x.length & 3)
      end

      def self.unpack(socket, size)
        val = socket.read(size)
        unused_padding = (4 - (size % 4)) % 4
        socket.read(unused_padding)
        val
      end
    end

    # List.of(Foo)
    # In this document the List.of notation strictly means some number of
    # repetitions of the FOO encoding; the actual length of the list is encoded
    # elsewhere

    class List
      def self.of(type)
      end
    end

  end
end
