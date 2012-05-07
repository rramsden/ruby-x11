module X11

  class DisplayError < X11Error; end
  class ConnectionError < X11Error; end
  class AuthorizationError < X11Error; end

  class Display

    # Open a connection to the specified display (numbered from 0) on the specified host
    def initialize(target = ENV['DISPLAY'])
      target =~ /^([\w.-]*):(\d+)(?:.(\d+))?$/
      host, display_id, screen_id = $1, $2, $3
      family = nil

      if host.empty?
        @socket = UNIXSocket.new("/tmp/.X11-unix/X#{display_id}")
        family = :Local
        host = nil
      else
        @socket = TCPSocket.new(host,6000+display_id)
        family = :Internet
      end

      authorize(host, family, display_id)
    end

    private

    def authorize(host, family, display_id)
      auth_info = Auth.new.get_by_hostname(host||"localhost", family, display_id)
      auth_name, auth_data = auth_info.address, auth_info.auth_data

      handshake = Packet::ClientHandshake.create(
        Protocol::BYTE_ORDER,
        Protocol::MAJOR,
        Protocol::MINOR,
        auth_name,
        auth_data
      )

      @socket.write(handshake)

      case @socket.read(1).unpack("w").first
      when X11::Auth::FAILED
        len, major, minor, xlen = @socket.read(7).unpack("CSSS")
        reason = @socket.read(xlen * 4)
        reason = reason[0..len]
        raise AuthorizationError, "Connection to server failed -- (version #{major}.#{minor}) #{reason}"
      when X11::Auth::AUTHENTICATE
        raise AuthorizationError, "Connection requires authentication"
      when X11::Auth::SUCCESS
        puts "SUCCESS"
      else
        raise AuthorizationError, "Received unknown opcode #{type}"
      end

    end
  end
end
