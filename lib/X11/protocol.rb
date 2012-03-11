module X11

  class ProtocolError < X11Error; end
  class ByteOrderError < ProtocolError; end

  class Protocol

    # endiness of your machine
    BYTE_ORDER = case [1].pack("L")
      when "\0\0\0\1"
        "B"
      when "\1\0\0\0"
        "l"
      else
        raise ByteOrderError.new "Cannot determine byte order"
    end

    MAJOR = 11
    MINOR = 0

  end
end
