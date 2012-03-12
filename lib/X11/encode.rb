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

    Unused    = "\x00"
    Int8      = pack("c")
    Int16     = pack("s")
    Int32     = pack("l")
    Uint8     = pack("C")
    Uint16    = pack("S")
    Uint32    = pack("L")
    String8   = lambda {|a| pad(a)}

    Keycode   = Uint8
    #Button    = Uint8
    
    # a CustomType class
    # instance variables can be set by the block
    # E.G.:
    # CustomType.new() { |a_var, an_other_var| a_var = 5; an_other_var = 10 }
    # will create a CustomType object with 
    #  @a_var = 5
    #  @an_other_var = 10
    #
    # 
    class CustomType
      def initialize &block
        ivars = block.parameters.map do |ary|
          name = ary.last
          name = name.to_s.insert(0, "@" ).to_sym unless name.to_s.start_with? "@"
          name
        end
        ivars.each { |vname| instance_variable_set vname, nil }
        ivars.map! { |iv| instance_variable_get iv } # instance variable name to instance variable
        yield *ivars
      end
    end

    VisualID # is an Atom ? 
    Bool # { true, false }
    Event #{KeyPress, KeyRelease, OwnerGrabButton, ButtonPress,
    # ButtonRelease, EnterWindow, LeaveWindow, PointerMotion,
    # PointerMotionHint, Button1Motion, Button2Motion,
    # Button3Motion, Button4Motion, Button5Motion, ButtonMotion,
    # Exposure, VisibilityChange, StructureNotify, ResizeRedirect,
    # SubstructureNotify, SubstructureRedirect, FocusChange,
    # PropertyChange, ColormapChange, KeymapState}

    Window    # 32-bit value (top three bits guaranteed to be zero)
    ColorMap  # 32-bit value (top three bits guaranteed to be zero)

    def list klass
      # do stuff
    end

    def set klass
      # do stuff
    end
    
  end
end
