extends CharacterBody3D


const SPEED = 6.5;
const JUMP_VELOCITY = 15;

var resources = 0;
var pickaxeLevel = 1;
@onready var resourceCounter = $UI/ResourceLabel

var canMine: bool = false;
var pickaxeEnabled: bool = false;
var canTalk: bool = false;
var gamePaused: bool = false;
var canJump;

var jerryLevel = 0;
var dealLevel = 0;
var npcTalk: int = 0;

@onready var pivot: Node3D = $Pivot
@onready var animPlayer: AnimationPlayer = $AnimationPlayer
@onready var pickaxe = $Holder/pickaxe
@onready var badPickaxe = $Holder/badpickaxe
@onready var coffee = $Holder/appleespresso
@onready var pauseMenu = $UI/Pause
@onready var music = $AudioStreamPlayer3D

@export_category("Sensitivity")
@export var xSens: float = 0.5;
@export var ySens: float = 0.5;


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pickaxe.visible = false;
	Dialogic.signal_event.connect(_on_dialogic_signal);
	pauseMenu.visible = false;
	gamePaused = false;
	music.play();
	canJump = false;
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and !gamePaused:
		rotate_y(deg_to_rad(-event.relative.x * xSens))
		pivot.rotate_x(clamp((deg_to_rad(-event.relative.y * ySens)), -30, 90))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-70), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if !gamePaused:
		if not is_on_floor():
			velocity += get_gravity() * delta

		if Input.is_action_just_pressed("Escape"):
			if Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			gamePaused = true;
			pauseMenu.visible = true;
			

				
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor() and canJump and Dialogic.current_timeline == null:
			velocity.y = JUMP_VELOCITY

		if Input.is_action_just_pressed("Mine") and canMine and pickaxeEnabled:
			print_debug("swing")
			animPlayer.play("pickaxeSwing");
			updateResources();
		elif Input.is_action_just_pressed("Mine") and pickaxeEnabled:
			animPlayer.play("pickaxeWhiff")

		

		if Input.is_action_just_pressed("ui_accept") and canTalk:
			match npcTalk:
				1:
					if (resources >= 100):
						jerryLevel += 1;
					match jerryLevel:
						0:
							if Dialogic.current_timeline == null:
								Dialogic.start("introWithJerry")
								jerryLevel += 1;
								dealLevel = 1; 
						1:
							if Dialogic.current_timeline == null:
								Dialogic.start("jerryDismissal")
						2:
							if Dialogic.current_timeline == null:
								Dialogic.start("jerryEnd")
						_:
							print_debug("error" + str(jerryLevel));

				2:
					match dealLevel:
						1:
							if Dialogic.current_timeline == null: 
								print_debug("Talking with the guy")
								Dialogic.start("mysterydialogue")
						2: 
							pass
						_:
							print_debug("Error" + str(dealLevel))


		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		move_and_slide()

func _on_rock_area_entered(area:Area3D) -> void:
	if (area.is_in_group("player")):
		canMine = true;
		print_debug("Can mine")


func _on_rock_area_exited(area:Area3D) -> void:
	if (area.is_in_group("player")):
		canMine = false;
		print_debug("Can't mine")
		
func updateResources() -> void:
	resourceCounter.text = "Resources: " + str(resources)

func mine() -> void:
	match pickaxeLevel:
		1:
			resources += 0.01
		2:
			resources += 10
		3:
			resources += 500


func _on_npc_area_entered(area: Area3D) -> void:
	if (area.is_in_group("player")):
		canTalk = true;
		npcTalk = 1


func _on_npc_area_exited(area: Area3D) -> void:
	if (area.is_in_group("player")):
		canTalk = false;
		npcTalk = 1



func _on_npc_2_area_exited(area:Area3D) -> void:
	if (area.is_in_group("player")):
		canTalk = false;
		npcTalk = 2

func _on_npc_2_area_entered(area:Area3D) -> void:
	if (area.is_in_group("player")):
		canTalk = true;
		npcTalk = 2

func _on_dialogic_signal(argument:String):
	if argument == "openPick":
		print_debug("worked???");
		pickaxeEnabled = true;
		badPickaxe.visible = true;
	if argument == "coffeeShot":
		badPickaxe.visible = false;
		coffee.visible = true;
		pickaxeLevel += 1;
	if argument == "enableJump":
		canJump = true;
		


func _on_resume_button_down() -> void:
	gamePaused = false;
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	pauseMenu.visible = false;




func _on_restart_button_down() -> void:
	get_tree().reload_current_scene();


func _on_quit_button_down() -> void:
	get_tree().quit();





	
