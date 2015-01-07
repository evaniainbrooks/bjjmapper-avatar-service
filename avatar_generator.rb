require 'RMagick'
require './color_generator'

class AvatarGenerator
  include Magick

  def self.avatar_for(options)
    image_text = initials_for(options[:name])
    image_width, half_width = options[:width], options[:width]/2
    image_height, half_height = options[:height], options[:height]/2
    color = ColorGenerator.color_for(options[:name])
    point_size = 22 + (image_width)/5

    img = Image.new(image_width, image_height) {
      self.background_color = 'transparent'
    }

    circle_draw = Draw.new {
      self.fill = color
    }

    circle_draw.circle(half_width, half_height, half_width, image_height-1)
    circle_draw.draw(img)
    
    font_draw = Draw.new {
      self.font_family ='helvetica'
      self.pointsize = point_size
      self.gravity = CenterGravity
    }

    font_draw.annotate(img, 0, 0, 0, 5, image_text) {
      self.fill = 'black'
    }

    img.format = options[:format]
    img.to_blob
  end

  def self.initials_for(name)
    name.split(/\W/).take(3).map{|tok| tok[0].upcase }.join('')
  end
end

