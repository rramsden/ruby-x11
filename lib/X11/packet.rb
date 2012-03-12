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

    class ConnectionAccept < BasePacket
      field :success #, type?
      field :static, Unused
      field :proto_major_version, Uint16
      field :proto_version_minor, Uint16
      field :additional_data#, length in 4-byte units of "additional data"
      field :release_number, Uint32
      field :resource_id_base, Uint32
      field :resource_id_mask, Uint32
      field :motion_buffer_size, Uint32
      field :length_of_vendor #, type?
      field :max_request_length, Uint16
      field :num_screens_in_root, Uint8
      field :num_formats_in_pixmap_formats #, type?
      field :img_byte_order #, type?: CustomType.new() { |lsbfirst, msbfirst| ... }
        # LSBFirst
        # MSBFirst
      field :bitmap_bit_order #, type?
        # LeastSignificant
        # MostSignificant
      field :bitmap_format_scanline_unit, Uint8
      field :bitmap_format_scanline_pad, Uint8
      field :min_keycode, Keycode
      field :max_keycode, Keycode
      field :static, Unused
      field :vendor, String8
      field :static, Unused
      field :pixmap_formats#, list( Format )
      field :roots#, list( Screen )

    end

    class SubPackage < BasePackage; end

    class Format < SubPackage
      field :depth, Uint8
      field :bits_per_pixel, Uint8
      field :scanline_pad, Uint8 
      field :static, Unused
    end

    class Screen < SubPackage
      field :root, Window
      field :default_colormap, ColorMap
      field :white_pixel, Uint32
      field :black_pixel, Uint32
      field :current_input_masks, set( Event )
      field :width_in_pixel, Uint16
      field :height_in_pixel, Uint16
      field :width_in_mm, Uint16
      field :height_in_mm, Uint16
      field :min_installed_maps, Uint16
      field :max_installed_maps, Uint16
      field :root_visual, VisualID
      #field :backing_stores #, type?: CustomType.new() { |never, when_mapped, always| ... } 
        # 0 Never
        # 1 WhenMapped
        # 2 Always
      field :save_unders, Bool
      field :root_depth, Uint8
      field :number_of_depths_in_allowed_depths, Uint8
      field :allowed_depths, list( Depth )
    end

    class Depth < SubPackage
      field :depth, Uint8
      field :static, Unused
      field :number_of_visualtypes_in_visuals #, type?
      field :static, Unused
      field :visuals, list( VisualType )
    end

    class VisualType < SubPackage
      field :visual_id, VisualID
      #field :class, type?: CustomType.new() { |static_gray, ... | ... }
        # 0 StaticGray
        # 1 GrayScale
        # 2 StaticColor
        # 3 PseudoColor
        # 4 TrueColor
        # 5 DirectColor
      field :bits_per_rbg_value, Uint8
      field :colormap_entries, Uint16
      field :red_mask, Uint32
      field :green_mask, Uint32
      field :blue_mask, Uint32
      field :static, Unused
    end

  end
end
