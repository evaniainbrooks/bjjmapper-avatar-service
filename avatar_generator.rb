require 'RMagick'
require './color_generator'

class AvatarGenerator
  include Magick

  POINT_SIZE = 42
  IMAGE_WIDTH = 100
  IMAGE_HEIGHT = 100

  def self.avatar_for(options)
    img_text = initials_for(options[:name])
    color = ColorGenerator.color_for(options[:name])
    img = Image.new(IMAGE_WIDTH, IMAGE_HEIGHT) {
      self.background_color = 'transparent'
    }

    circle_draw = Draw.new {
      self.fill = color
    }

    circle_draw.circle(IMAGE_WIDTH / 2, IMAGE_HEIGHT / 2, IMAGE_WIDTH / 2, IMAGE_HEIGHT-1)
    circle_draw.draw(img)
    font_draw = Draw.new {
      self.font_family ='helvetica'
      self.pointsize = POINT_SIZE
      self.gravity = CenterGravity
    }

    font_draw.annotate(img, 0, 0, 0, 5, img_text) {
      self.fill = 'black'
    }

    img.format = options[:format]
    img.to_blob
  end

  def self.initials_for(name)
    name.split(/\W/).take(3).map{|tok| tok[0].upcase }.join('')
  end
end

