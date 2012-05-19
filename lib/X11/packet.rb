module X11
  module Packet

    class BasePacket
      include X11::Type

      class << self
        def create(*parameters)
          lengths = lengths_for(parameters)

          packet = @structs.map do |s|
            case s.type
            when :field
              s.type_klass.pack(parameters.shift)
            when :unused
              "\x00" * s.size
            when :length
              s.type_klass.pack(lengths[s.name])
            when :string
              s.type_klass.pack(parameters.shift)
            when :list
              parameters.shift.each do |obj|
                s.type_klass.create(*obj)
              end
            end
          end

          ((@opcode ? [X11::Type::Int8.pack(@opcode)] : []) + packet).join
        end

        def read(socket)
          lengths = {}
          values = {}

          @structs.each do |s|
            case s.type
            when :field
              values[s.name] = s.type_klass.unpack( socket.read(s.type_klass.size) )
            when :unused
              socket.read(s.size)
            when :length
              size = s.type_klass.unpack( socket.read(s.type_klass.size) )
              lengths[s.name] = size
            when :string
              values[s.name] = s.type_klass.unpack(socket, lengths[s.name])
            when :list
              values[s.name] = lengths[s.name].times.collect do
                s.type_klass.read(socket)
              end
            end
          end

          OpenStruct.new(values)
        end

        def field(*args)
          name, type_klass, type = args
          s = Struct.new(:name, :type_klass, :type).new
          s.name = name
          s.type = (type == nil ? :field : type)
          s.type_klass = type_klass

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

        def opcode(value)
          @opcode = value
        end

        private

        def lengths_for(args)
          args = args.dup
          lengths = {}

          fields.each do |s|
            value = args.shift
            lengths[s.name] = value.size if s.type == :list or s.type == :string
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
  end
end
