#Including necessary library and file
require 'ruby2d'
require_relative 'tilemap.rb'

#Defining the objects
@hitbox = Square.new(x: -100, y: -100, size: 30, color: 'red', opacity: 0)
@player = Square.new(x: 270, y: 240, size: 30, color: 'green', opacity: 0)
@pacman = Sprite.new(
  'pacman_new.png',
  x: 270,
  y: 240,
  width: 30,
  height: 30,
  clip_width: 16,
  clip_height: 16,
  time: 100,
  animations: {
    standing: 2,
    horizontal: 0..1,
    vertical: [
      {
        x: 0, y: 16,
        width: 16, height: 16,
        time: 100
      },
      {
        x: 16, y: 16,
        width: 16, height: 16,
        time: 100
      }
    ]
  }
)

#Defining the map where true means a wall and false means no wall
@collision_map = [
  [true, true, true, true, true, true, true, true, false, true, false, true, false, true, true, true, true, true, true, true, true, true],
  [true, false, false, false, false, false, false, true, false, true, false, true, false, true, false, false, false, true, false, false, false, true],
  [true, false, true, true, false, true, false, true, false, true, false, true, false, true, false, true, false, false, false, true, false, true],
  [true, false, true, true, false, true, false, true, true, true, false, true, true, true, false, true, true, true, false, true, false, true],
  [true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, true],
  [true, false, true, true, false, true, true, true, true, true, false, true, true, true, false, true, false, true, true, true, false, true],
  [true, false, true, true, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false, true, false, true],
  [true, false, true, true, false, true, false, true, false, true, true, true, false, true, false, true, false, true, false, true, false, true],
  [true, false, false, false, false, true, false, false, false, true, false, true, false, true, false, false, false, true, false, false, false, true],
  [true, true, true, true, false, true, true, true, false, true, false, true, false, true, true, true, false, true, true, true, false, true],
  [true, false, false, false, false, true, false, false, false, true, false, true, false, true, false, false, false, true, false, false, false, true],
  [true, false, true, true, false, true, false, true, false, true, true, true, false, true, false, true, false, true, false, true, false, true],
  [true, false, true, true, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false, true, false, true],
  [true, false, true, true, false, true, true, true, true, true, false, true, true, true, false, true, false, true, true, true, false, true],
  [true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, true],
  [true, false, true, true, false, true, false, true, true, true, false, true, true, true, false, true, true, true, false, true, false, true],
  [true, false, true, true, false, true, false, true, false, true, false, true, false, true, false, true, false, false, false, true, false, true],
  [true, false, false, false, false, false, false, true, false, true, false, true, false, true, false, false, false, true, false, false, false, true],
  [true, true, true, true, true, true, true, true, false, true, false, true, false, true, true, true, true, true, true, true, true, true],
  [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
]

#Creating variables for pac-mans speed and where he is looking
@pacman_x_speed = 0
@pacman_y_speed = 0
@hitboxPosX = 0
@hitboxPosY = 0

#Main loop. If there isn't a wall(collision) pac-man will move in the direction he is facing,
#and the position will be updated. %Window.width/height makes it so he won't move outside the
#map, but appear on the other side of the screen instead.
update do
  if !collision
    @player.x = (@player.x + @pacman_x_speed) % Window.width
    @player.y = (@player.y + @pacman_y_speed) % Window.height
    playerPosition()
    hitboxPosition()
  end
end

#Will look for buttonpresses, and update pac-mans speed and the direction he is checking for walls
#(Hitbox Position). It will also play pac-mans animation and check for walls to make sure you don't move
#before checking for walls and phase through.
on :key_down do |event|
  if event.key == 'left'
    @pacman_x_speed = -2
    @pacman_y_speed = 0
    @hitboxPosX = -30
    @hitboxPosY = 0
    @pacman.play animation: :horizontal, loop: true, flip: :horizontal
    hitboxPosition()
  elsif event.key == 'right'
    @pacman_x_speed = 2
    @pacman_y_speed = 0
    @hitboxPosX = 30
    @hitboxPosY = 0
    @pacman.play animation: :horizontal, loop: true
    hitboxPosition()
  elsif event.key == 'up'
    @pacman_x_speed = 0
    @pacman_y_speed = -2
    @hitboxPosX = 0
    @hitboxPosY = -30
    @pacman.play animation: :vertical, loop: true
    hitboxPosition()
  elsif event.key == 'down'
    @pacman_x_speed = 0
    @pacman_y_speed = 2
    @hitboxPosX = 0
    @hitboxPosY = 30
    @pacman.play animation: :vertical, loop: true, flip: :vertical
    hitboxPosition()
  end
end

#Updates the direction pac-man is checking for walls, which will always be right in front of him in the
#direction he is facing.
def hitboxPosition
  @hitbox.x = (@player.x+@hitboxPosX)
  @hitbox.y = (@player.y+@hitboxPosY)
end

#Updates the position of the sprite. It makes it to an integer to make sure it's always whole numbers,
#so the sprite stays within the grid.
def playerPosition
  @x = ((@player.x)/30).to_int
  @y = ((@player.y)/30).to_int

  @pacman.x = @x*30
  @pacman.y = @y*30
end

#Checks the map to see if there is a wall where pac-man is facing/checking.
def collision
  return @collision_map[@hitbox.x/30][@hitbox.y/30]
end

show
