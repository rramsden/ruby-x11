module X11
  module Packet
    class BasePacket
      include X11::Encode

      @@struct = []

      class << self
        def create(*values)
          lengths = lengths_for(values)

          packet = @@struct.map do |tuple|
            type, name, encode_fun = tuple

            case type
            when :field
              encode_fun.call(values.shift)
            when :length
              encode_fun.call(lengths[name])
            when :unused
              name
            end

          end
          packet.join
        end

        def field(name, encode_fun)
          @@struct.push([:field, name, encode_fun])
        end

        def unused(size)
          @@struct.push([:unused, "\x00" * size])
        end

        def length(name, encode_fun)
          @@struct.push([:length, name, encode_fun])
        end

        private

        def lengths_for(args)
          args = args.dup
          lengths = {}

          fields.each do |type, name, klass|
            value = args.shift
            lengths[name] = value.size if value.is_a?(String)
          end

          return lengths
        end

        def fields
          @@struct.dup.delete_if do |type,name,klass|
            type == :unused or type == :length
          end
        end

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

    class ClientHandshake < BasePacket
      field :byte_order, Uint8
      unused 1
      field :protocol_major_version, Uint16
      field :protocol_minor_version, Uint16
      length :auth_proto_name, Uint16
      length :auth_proto_data, Uint16
      unused 1
      field :auth_proto_name, String8
      field :auth_proto_data, String8
    end
  end
end
