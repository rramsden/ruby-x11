module X11
  module Packet
    class BasePacket
      include X11::Encode

      attr_reader :packet
      @@fields = []

      def self.create(*values)
        @@fields.map do |name, type|
          if :static == name
            type
          else
            type.call(values.shift)
          end
        end.join
      end

      def self.field(name, type)
        @@fields.push([name, type])
      end
    end

    class ClientHandshake < BasePacket
      field :byte_order, Uint8
      field :static, "\x00"
      field :proto_version_major, Uint16
      field :proto_version_minor, Uint16
      field :auth_proto_name_length, Uint16
      field :auth_proto_data_length, Uint16
      field :static, "\x00"
      field :static, "\x00"
      field :auth_proto_name, String8
      field :auth_proto_data, String8
    end
  end
end
