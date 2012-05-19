require File.expand_path('../helper', __FILE__)

class MockSocket
  def initialize(packet)
    @packet = packet
  end

  def read(amount)
    @packet.slice!(0..amount-1)
  end
end

class Child < X11::Packet::BasePacket
  field :name, Uint16, :length
  field :name, String8, :string
end

class Parent < X11::Packet::BasePacket
  field :a, Uint8
  field :b, Uint16
  field :c, Uint32

  field :d, Uint16, :length
  field :d, String8, :string

  field :children, Uint16, :length
  field :children, Child, :list
end

describe X11::Packet::BasePacket do
  it "should create and read a packet" do
    children = []
    children << Child.create("#1")
    children << Child.create("#2")
    children << Child.create("#3")

    packet = Parent.create(1,2,3,"Hello World", children)
    socket = MockSocket.new(packet)
    reader = Parent.read(socket)

    reader.a.must_equal 1
    reader.b.must_equal 2
    reader.c.must_equal 3
    reader.d.must_equal "Hello World"

    reader.children.shift.name.must_equal("#1")
    reader.children.shift.name.must_equal("#2")
    reader.children.shift.name.must_equal("#3")
  end
end
