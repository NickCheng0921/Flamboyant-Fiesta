extends KinematicBody2D

export(float) var runSpeed = 250

var velocity = Vector2()
var puppet_pos = Vector2()
export(float) var jumpHeight = 40
export(float) var jumpTime = 0.2
var gravity = 2*jumpHeight/(jumpTime*jumpTime)

func _ready():
	puppet_pos = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position = puppet_pos
	#velocity = move_and_slide(velocity, Vector2(0, -1))
		
#https://godotengine.org/article/multiplayer-changes-godot-4-0-report-1
remote func update_state(p_pos, p_vel):
	puppet_pos = p_pos
	velocity = p_vel