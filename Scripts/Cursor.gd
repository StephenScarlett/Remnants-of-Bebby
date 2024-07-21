extends Sprite2D

var tile_size = Vector2(32,32)  # Size of your tiles
var grid_position = Vector2(0,0)
var grid_size = Vector2(10,10)  # Size of the grid (10x10 tiles for example)
var selected_sprite = null  # Store the reference to the selected sprite

@onready var BebG_sprite_real = $"../BebG"
@onready var BebG_sprite = $"../BebG2"
@onready var BebG_animation = BebG_sprite.get_node("AnimationPlayer")
@onready var BebG_movement = $"../MovementSpaces"
@onready var BebG_movement_tl = $"../MovementSpaces/TopLeft"
@onready var BebG_movement_br = $"../MovementSpaces/BottomRight"
@onready var BebG_movement_tr = $"../MovementSpaces/TopRight"
@onready var BebG_movement_bl = $"../MovementSpaces/BottomLeft"


var is_moving = false  # Track if we are currently moving a sprite

var move_delay = 0.2  # Delay in seconds between movements
var time_since_last_move = 0  # Timer to track time since the last move

func _ready():
	set_initial_position()
	update_position()

func _process(delta):
	var cursor_tile_position = grid_position * tile_size
	time_since_last_move += delta
	
	if time_since_last_move >= move_delay:
		var moved = false
		
		if Input.is_action_pressed("up"):
			grid_position.y -= 1
			moved = true
		if Input.is_action_pressed("down"):
			grid_position.y += 1
			moved = true
		if Input.is_action_pressed("left"):
			grid_position.x -= 1
			moved = true
		if Input.is_action_pressed("right"):
			grid_position.x += 1
			moved = true
			
		if moved:
			clamp_position()
			update_position()
			time_since_last_move = 0  # Reset the timer after a move
			
			if is_moving==true:
				update_selected_sprite_position(cursor_tile_position, BebG_sprite.position)
			
		# Check if the cursor is on the same tile as the existing sprite
		if is_on_same_tile(cursor_tile_position, BebG_sprite.position):
			if Input.is_action_just_pressed("select") and is_moving==false:
				select_sprite(BebG_sprite)
			elif Input.is_action_just_pressed("select") and is_moving==true:
				place_sprite()


func is_on_same_tile(cursor_pos: Vector2, sprite_pos: Vector2) -> bool:
	# Convert sprite position to tile coordinates and check if they match
	var sprite_tile_pos = sprite_pos / tile_size
	sprite_tile_pos = Vector2(round(sprite_tile_pos.x), round(sprite_tile_pos.y))
	var cursor_tile_pos = cursor_pos / tile_size
	cursor_tile_pos = Vector2(round(cursor_tile_pos.x), round(cursor_tile_pos.y))
	return cursor_tile_pos == sprite_tile_pos

func update_selected_sprite_position(cursor_pos: Vector2, sprite_pos: Vector2):
	if selected_sprite and is_moving == true:
		selected_sprite.position = grid_position * tile_size

func clamp_position():
	if selected_sprite==null:
		grid_position.x = clamp(grid_position.x, 0, grid_size.x - 1)
		grid_position.y = clamp(grid_position.y, 0, grid_size.y - 1)
	elif selected_sprite:
		grid_position.x = clamp(grid_position.x, (BebG_movement.position.x/32)-2, (BebG_movement.position.x/32)+2)
		grid_position.y = clamp(grid_position.y, (BebG_movement.position.y/32)-2, (BebG_movement.position.y/32)+2)

func update_position():
	position = grid_position * tile_size
	
func set_initial_position():
	var BebG_sprite_position = BebG_sprite.position
	grid_position = BebG_sprite_position / tile_size
	grid_position = Vector2(round(grid_position.x), round(grid_position.y))  # Use round to ensure correct alignment

func select_sprite(sprite):
	BebG_animation.play("selected")
	BebG_sprite.visible = true
	BebG_movement.visible = true
	selected_sprite = sprite
	is_moving = true
	print("Sprite selected")


func place_sprite():
	if selected_sprite:
		BebG_animation.stop()
		BebG_sprite.visible = false
		BebG_movement.visible = false
		grid_size = Vector2(10,10)
		BebG_movement.position = grid_position * tile_size
		selected_sprite = null  # Deselect the sprite
		is_moving = false
		BebG_sprite_real.position = BebG_sprite.position
		print("Sprite placed at new position")
