module X11
  module Packet

    class ClientHandshake < BasePacket
      field :byte_order, Uint8
      unused 1
      field :protocol_major_version, Uint16
      field :protocol_minor_version, Uint16
      field :auth_proto_name, Uint16, :length
      field :auth_proto_data, Uint16, :length
      unused 2
      field :auth_proto_name, String8, :string
      field :auth_proto_data, String8, :string
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
      field :visuals, VisualInfo, :list
    end

    class ScreenInfo < BasePacket
      field :root, Window
      field :default_colormap, Colormap
      field :white_pixel, Colornum
      field :black_pixel, Colornum
      field :current_input_masks, EventMask
      field :width_in_pixels, Uint16
      field :height_in_pixels, Uint16
      field :width_in_millimeters, Uint16
      field :height_in_millimeters, Uint16
      field :min_installed_maps, Uint16
      field :max_installed_maps, Uint16
      field :root_visual, VisualID
      field :backing_stores, Uint8
      field :save_unders, Bool
      field :root_depth, Uint8
      field :depths, Uint8,:length
      field :depths, DepthInfo, :list
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
      unused 4
      field :vendor, String8, :string
      field :formats, FormatInfo, :list
      field :screens, ScreenInfo, :list
    end

  end
end
