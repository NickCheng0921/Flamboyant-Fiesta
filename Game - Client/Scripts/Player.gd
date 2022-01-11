extends KinematicBody2D

export(float) var runSpeed = 250

var velocity = Vector2()
var puppet_pos = Vector2()
export(float) var jumpHeight = 60
export(float) var jumpTime = 0.2
var gravity = 2*jumpHeight/(jumpTime*jumpTime)

func _ready():
	puppet_pos = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_network_master():
		puppet_pos = get_node(".").get_position()
		var move = 0.0
		#movement
		if(Input.is_action_pressed("ui_right")):
			move += 1
			
		if(Input.is_action_pressed("ui_left")):
			move -= 1
			
		if(Input.is_action_just_pressed("jump") && is_on_floor()):
			velocity.y = -2*jumpHeight/jumpTime
			
		#walljump
		#if(Input.is_action_just_pressed("jump") && is_on_floor() == false && is_on_wall()):
		#	velocity.y = -2*jumpHeight/jumpTime
			
		#movement calculations
		# -y is up, +y is down
		velocity.y += gravity*delta
		velocity.x = move * runSpeed
		move_and_slide(velocity, Vector2(0, -1))
		rpc("update_state", position, velocity)
	else:
		position = puppet_pos
		velocity = move_and_slide(velocity, Vector2(0, -1))

func connect_readyArea():
	if is_network_master():
		get_node("../ReadyArea").connect("body_entered", self, "enterReadyArea")
		get_node("../ReadyArea").connect("body_exited",  self, "exitReadyArea")

#https://godotengine.org/article/multiplayer-changes-godot-4-0-report-1
remote func update_state(p_pos, p_vel):
	puppet_pos = p_pos
	velocity = p_vel

func enterReadyArea(body):
	#signal gets propagated to all other master player nodes
	if body.name == self.name:
		$"../".rpc_id(1, "player_ready", get_tree().get_network_unique_id(), true)
		
func exitReadyArea(body):
	if body.name == self.name:
		$"../".rpc_id(1, "player_ready", get_tree().get_network_unique_id(), false)
