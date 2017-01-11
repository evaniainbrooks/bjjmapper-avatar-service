require 'RMagick'
require_relative 'color_generator'

class AvatarGenerator
  include Magick

  def self.avatar_for(options)
    image_text = initials_for(options[:name])
    image_width, half_width = options[:width], options[:width]/2
    image_height, half_height = options[:height], options[:height]/2
    color_components = ColorGenerator.color_for(options[:name])
    color = "##{color_components.join}"
    point_size = 20 + (image_width)/5

    img = Image.new(image_width, image_height) {
      self.background_color = 'transparent'
    }

    outer_circle_draw = Draw.new {
      self.fill = "#000000"
    }

    circle_draw = Draw.new {
      self.fill = color
    }

    outer_circle_draw.circle(half_width, half_height, half_width, image_height - 1)
    outer_circle_draw.draw(img)

    circle_draw.circle(half_width, half_height, half_width - 2, image_height - 3)
    circle_draw.draw(img)

    font_draw = Draw.new {
      self.font_family ='helvetica'
      self.pointsize = point_size
      self.gravity = CenterGravity
    }

    font_draw.annotate(img, 0, 0, 0, 5, image_text) {
      self.fill = (AvatarGenerator.color_is_light?(color_components) ? 'black' : 'white')
    }

    img.format = options[:format]
    img.quality = 10
    img.to_blob
  end

  def self.color_is_light?(color)
    r = color[0].to_i(16)
    g = color[1].to_i(16)
    b = color[2].to_i(16)

    a = 1 - (0.299 * r + 0.587 * g + 0.114 * b) / 255
    return (a < 0.5)
  end

  def self.initials_for(name)
    name.split(/\W/).take(3).map{|tok| tok[0].upcase }.join('')
  end
end

