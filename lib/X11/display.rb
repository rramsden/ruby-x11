module X11

  class DisplayException < X11Exception; end
  class ConnectionException < DisplayException; end

  class AuthorizationException < ConnectionException
    attr_reader :errorcode
    def initialize msg, errcode=nil
      super msg
      @errorcode = errcode
    end
  end

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
        auth_name.length,
        auth_data.length,
        auth_name,
        auth_data
      )

      @socket.write(handshake)

      case @socket.read(1).unpack("w").first
        when X11::Auth::FAILED
          len, major, minor, xlen = @socket.read(7).unpack("CSSS")
          reason = @socket.read(xlen * 4)
          reason = reason[0..len] 
          raise AuthorizationException.new "Connection to server failed -- (version #{major}.#{minor}) #{reason}", X11::Auth::FAILED
        when X11::Auth::AUTHENTICATE
          raise AuthorizationException.new "Connection requires authentication", X11::Auth::AUTHENTICATE
        when X11::Auth::SUCCESS
          puts "CONNECTION SUCCESS"
        else
          raise AuthorizationException.new "Received unknown opcode #{type}" 
      end

    end
  end
end
