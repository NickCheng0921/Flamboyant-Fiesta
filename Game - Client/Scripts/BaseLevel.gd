extends Node2D

#waterfall is 21 pixels in height
var waterfall_height = 21
#there are currently 2 separate waterfall tiles, respectively single tile 5 and single tile 6 in the TileSet
var fall_1 = 5
var fall_2 = 6
var water = 7
#the waterfall is 3 tiles thick and goes from x:-2 to x:0
var time = 1.5/waterfall_height
var curr_time = time
var y_pos := 0

func _ready():
	var y_pos = -1*waterfall_height

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	curr_time -= delta
	if curr_time < 0:
		print(y_pos)
		curr_time = time
		if y_pos >= -1:
			y_pos = -1*waterfall_height
			$"./TileMap".set_cellv(Vector2(0,-1), water)
		else:
			y_pos += 1
			$"./TileMap".set_cellv(Vector2(0,y_pos-1), water)
			$"./TileMap".set_cellv(Vector2(0,y_pos), fall_1)
		
	
