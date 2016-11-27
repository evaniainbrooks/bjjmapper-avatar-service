require 'zlib'

class ColorGenerator
  RED_COMPONENTS = ["FF", "CC", "33", "66", "99", "FF", "33"].freeze
  GREEN_COMPONENTS = ["99", "FF", "33", "33", "66", "CC"].freeze
  BLUE_COMPONENTS = ["33", "FF", "66", "33", "99", "CC", "99"].freeze

  def self.color_for(name)
    digest = Zlib.crc32(name)
    return [r(digest), g(digest), b(digest)]
  end

  private

  def self.r(digest)
    RED_COMPONENTS[digest % RED_COMPONENTS.count]
  end

  def self.g(digest)
    GREEN_COMPONENTS[digest % GREEN_COMPONENTS.count]
  end

  def self.b(digest)
    BLUE_COMPONENTS[digest % BLUE_COMPONENTS.count]
  end
end
