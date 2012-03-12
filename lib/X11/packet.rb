module X11
  module Packet
    class BasePacket
      include X11::Encode
      @@fields = []

      # Takes a list of ruby objects and encodes them
      # to binary data-types defined in X11::Encode
      def self.create(*values)
        @@fields.map do |name, type|
          name == :static ? type : type.call( values.shift )
        end.join
      end

      def self.field(name, type)
        @@fields.push([name, type])
      end
    end

    # Information sent by the client at connection setup
    #
    # 1                        byte-order
    #      #x42    MSB first
    #      #x6C    LSB first
    # 1                        unused
    # 2    CARD16              protocol-major-version
    # 2    CARD16              protocol-minor-version
    # 2    n                   length of authorization-protocol-name
    # 2    d                   length of authorization-protocol-data
    # 2                        unused
    # n    STRING8             authorization-protocol-name
    # p                        unused, p=pad(n)
    # d    STRING8             authorization-protocol-data
    # q                        unused, q=pad(d)
    #
    class ClientHandshake < BasePacket
      field :byte_order, Uint8
      field :static, Unused 
      field :proto_version_major, Uint16
      field :proto_version_minor, Uint16
      field :auth_proto_name_length, Uint16
      field :auth_proto_data_length, Uint16
      field :static, Unused
      field :static, Unused
      field :auth_proto_name, String8
      field :auth_proto_data, String8
    end
  end
end
