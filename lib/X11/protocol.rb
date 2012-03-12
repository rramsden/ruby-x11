module X11
  module Protocol
    # endiness of your machine
    BYTE_ORDER = case [1].pack("L")
      when "\0\0\0\1"
        "B".ord
      when "\1\0\0\0"
        "l".ord
      else
        raise ByteOrderError.new "Cannot determine byte order"
    end

    MAJOR = 11
    MINOR = 0
  end
end
