module X11
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

    # authorization packet sent to X11 server:
    #   [:proto_major, Uint16],
    #   [:proto_minor, Uint16],
    #   [:auth_proto_name, Uint16, :length],
    #   [:auth_proto_data, Uint16, :length],
    #   [:auth_proto_name, String8],
    #   [:auth_proto_data, String8]
    def authorize(host, family, display_id)
      auth_info = Auth.new.get_by_hostname(host||"localhost", family, display_id)
      auth_name, auth_data = auth_info.address, auth_info.auth_data
      puts auth_name
      puts auth_data
      
      @socket.write([
        Protocol::BYTE_ORDER,
        Protocol::MAJOR,
        Protocol::MINOR,
        auth_name.length,
        auth_data.length,
        X11::pad(auth_name),
        X11::pad(auth_data)
      ].pack("A2 SS SS xx") + X11::pad(auth_name) + X11::pad(auth_data))

      case @socket.read(1).unpack("w").first
        when X11::Auth::FAILED
          len, major, minor, xlen = @socket.read(7).unpack("CSSS")
          reason = @socket.read(xlen * 4)
          reason = reason[0..len] 
          raise "Connection to server failed -- (version #{major}.#{minor}) #{reason}"
        when X11::Auth::AUTHENTICATE
          raise "Connection requires authentication"
        when X11::Auth::SUCCESS
          raise "fix me"  
        else
          raise "received unknown opcode #{type}"
      end
    end
  end
end
