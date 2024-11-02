extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var resources = 0;
var pickaxeLevel = 1;
@onready var resourceCounter = $UI/ResourceLabel

var canMine: bool = false
var canTalk: bool = false

@onready var pivot: Node3D = $Pivot
@onready var animPlayer: AnimationPlayer = $AnimationPlayer

@export_category("Sensitivity")
@export var xSens: float = 0.5
@export var ySens: float = 0.5


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * xSens))
		pivot.rotate_x(clamp((deg_to_rad(-event.relative.y * ySens)), -30, 90))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-70), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("Escape"):
		if Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("Mine") and canMine:
		animPlayer.play("pickaxeSwing")
		updateResources();

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


func _on_npc_area_exited(area: Area3D) -> void:
	if (area.is_in_group("player")):
		canTalk = false;
