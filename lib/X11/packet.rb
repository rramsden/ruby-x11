module X11
  module Packet

    class BasePacket
      include X11::Type

      class << self
        def create(*values)
          lengths = lengths_for(values)

          packet = @structs.map do |s|
            case s.type
            when :field
              s.encode.pack(values.shift)
            when :unused
              "\x00" * s.size
            when :length
              s.encode.pack(lengths[s.name])
            when :data
              if s.encode == X11::Type::String8
                X11::Type::String8.pack(values.shift)
              else
                vals = s.encode.create(values.shift)
              end
            end
          end

          packet.join
        end

        def read(socket)
          lengths = {}
          values = {}

          @structs.each do |s|
            case s.type
            when :field
              values[s.name] = s.encode.unpack( socket.read(s.encode.size) )
            when :unused
              socket.read(s.size)
            when :length
              size = s.encode.unpack( socket.read(s.encode.size) )
              lengths[s.name] = size
            when :data
              if s.encode == X11::Type::String8
                values[s.name] = X11::Type::String8.unpack(socket, s.size)
              else
                puts lengths[s.name]
                values[s.name] = lengths[s.name].times.collect do
                  s.encode.read(socket)
                end
              end
            end
          end

          values
        end

        def field(*args)
          name, encode, type = args
          puts name
          s = Struct.new(:name, :encode, :type).new
          s.name = name
          s.type = (type == nil ? :field : type)
          s.encode = encode

          @structs ||= []
          @structs << s
        end

        def unused(size)
          s = Struct.new(:size, :type).new
          s.size = size
          s.type = :unused

          @structs ||= []
          @structs << s
        end

        private

        def lengths_for(args)
          args = args.dup
          lengths = {}

          fields.each do |s|
            value = args.shift
            lengths[s.name] = value.size if s.type == :data
          end

          return lengths
        end

        def fields
          @structs.dup.delete_if do |s|
            s.type == :unused or s.type == :length
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
      field :auth_proto_name, Uint16, :length
      field :auth_proto_data, Uint16, :length
      unused 2
      field :auth_proto_name, String8, :data
      field :auth_proto_data, String8, :data
    end

    class FormatInfo < BasePacket
      field :depth, Uint8
      field :bits_per_pixel, Uint8
      field :scanline_pad, Uint8
      unused 5
    end

    class VisualInfo < BasePacket
      field :visual_id, VisualID
      field :qlass, Uint8
      field :bits_per_rgb_value, Uint8
      field :colormap_entries, Uint16
      field :red_mask,  Uint32
      field :green_mask, Uint32
      field :blue_mask, Uint32
      unused 4
    end

    class DepthInfo < BasePacket
      field :depth, Uint8
      unused 1
      field :visuals, Uint16, :length
      unused 4
      field :visuals, VisualInfo, :data
    end

    class ScreenInfo < BasePacket
      field :root, Window
      field :default_colormap, Colormap
      field :white_pixel, Colornum
      field :black_pixel, Colornum
      field :current_input_masks, EventMask
      field :size_in_pixels, Uint16
      field :size_in_millimeters, Uint16
      field :min_installed_maps, Uint16
      field :max_installed_maps, Uint16
      field :root_visual, VisualID
      field :backing_stores, Uint8
      field :save_unders, Bool
      field :root_depth, Uint8
      field :depths, Uint8,:length
      field :depths, DepthInfo, :data
    end

    class DisplayInfo < BasePacket
      field :release_number, Uint32
      field :resource_id_base, Uint32
      field :resource_id_mask, Uint32
      field :motion_buffer_size, Uint32
      field :vendor, Uint16, :length
      field :maximum_request_length, Uint16
      field :screens, Uint8, :length
      field :formats, Uint8, :length
      field :image_byte_order, Signifigance
      field :bitmap_bit_order, Signifigance
      field :bitmap_format_scanline_unit, Uint8
      field :bitmap_format_scanline_pad, Uint8
      field :min_keycode, KeyCode
      field :max_keycode, KeyCode
      field :vendor, String8, :data
      field :formats, FormatInfo, :data
      field :screens, ScreenInfo, :data
    end

  end
end
