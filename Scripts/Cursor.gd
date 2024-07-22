extends Sprite2D

var tile_size = Vector2(32,32)  # Size of your tiles
var cursor_grid_position = Vector2(0,0)
var grid_size = Vector2(10,10)  # Size of the grid (10x10 tiles for example)

var selected_sprite = null  # Store the reference to the selected sprite
var selection_menu = false

@onready var BebG_sprite_real = $"../BebGg"
@onready var BebG_select_shadow = $"../BebGSelectShadow"
@onready var BebG_select_shadow_animation = $"../BebGSelectShadow/AnimationPlayer"
@onready var BebG_movement_tiles_2 = $"../BebGMovementTiles_2"
@onready var SelectionMenu = $"Camera2D/UI Elements/SelectionMenu"

@onready var AttackButton = $"Camera2D/UI Elements/MarginContainer/VBoxContainer/Attack"


var is_moving = false  # Track if we are currently moving a sprite

var move_delay = 0.2  # Delay in seconds between movements
var time_since_last_move = 0  # Timer to track time since the last move

func _ready():
	set_initial_position()
	update_position()

func _process(delta):
	var cursor_tile_position = cursor_grid_position * tile_size
	time_since_last_move += delta
	
	if time_since_last_move >= move_delay:
		var moved = false
		
		if selection_menu==false:
			if Input.is_action_pressed("ui_up"):
				cursor_grid_position.y -= 1
				moved = true
			if Input.is_action_pressed("ui_down"):
				cursor_grid_position.y += 1
				moved = true
			if Input.is_action_pressed("ui_left"):
				cursor_grid_position.x -= 1
				moved = true
			if Input.is_action_pressed("ui_right"):
				cursor_grid_position.x += 1
				moved = true
			
		if moved:
			clamp_position()
			update_position()
			time_since_last_move = 0  # Reset the timer after a move
			
			if is_moving==true:
				update_selected_sprite_position(cursor_tile_position, BebG_select_shadow.position)
			
		# Check if the cursor is on the same tile as the existing sprite
		if is_on_same_tile(cursor_tile_position, BebG_select_shadow.position):
			if Input.is_action_just_pressed("ui_accept") and is_moving==false:
				select_sprite(BebG_select_shadow)
			elif Input.is_action_just_pressed("ui_accept") and is_moving==true and selection_menu==false:
				open_selection_menu()


func is_on_same_tile(cursor_pos: Vector2, sprite_pos: Vector2) -> bool:
	# Convert sprite position to tile coordinates and check if they match
	var sprite_tile_pos = sprite_pos / tile_size
	sprite_tile_pos = Vector2(round(sprite_tile_pos.x), round(sprite_tile_pos.y))
	var cursor_tile_pos = cursor_pos / tile_size
	cursor_tile_pos = Vector2(round(cursor_tile_pos.x), round(cursor_tile_pos.y))
	return cursor_tile_pos == sprite_tile_pos

func update_selected_sprite_position(cursor_pos: Vector2, sprite_pos: Vector2):
	if selected_sprite and is_moving == true:
		selected_sprite.position = cursor_grid_position * tile_size

func clamp_position():
	if selected_sprite==null:
		cursor_grid_position.x = clamp(cursor_grid_position.x, 0, grid_size.x - 1)
		cursor_grid_position.y = clamp(cursor_grid_position.y, 0, grid_size.y - 1)
	elif selected_sprite:
		cursor_grid_position.x = clamp(cursor_grid_position.x, (BebG_movement_tiles_2.position.x/32)-2, (BebG_movement_tiles_2.position.x/32)+2)
		cursor_grid_position.y = clamp(cursor_grid_position.y, (BebG_movement_tiles_2.position.y/32)-2, (BebG_movement_tiles_2.position.y/32)+2)

func update_position():
	position = cursor_grid_position * tile_size
	
func set_initial_position():
	var BebG_sprite_position = BebG_select_shadow.position
	cursor_grid_position = BebG_sprite_position / tile_size
	cursor_grid_position = Vector2(round(cursor_grid_position.x), round(cursor_grid_position.y))  # Use round to ensure correct alignment

func select_sprite(sprite):
	BebG_select_shadow_animation.play("selected")
	BebG_select_shadow.visible = true
	BebG_movement_tiles_2.visible = true
	selected_sprite = sprite
	is_moving = true
	print("Sprite selected")

func open_selection_menu():
	if selected_sprite:
		SelectionMenu.visible = true
		selection_menu=true
		AttackButton.grab_focus()
		#place_sprite()

func place_sprite():
	if selected_sprite:
		BebG_select_shadow_animation.stop()
		BebG_select_shadow.visible = false
		BebG_movement_tiles_2.visible = false
		grid_size = Vector2(10,10)
		BebG_movement_tiles_2.position = cursor_grid_position * tile_size
		
		SelectionMenu.visible = false
		selection_menu=false
		
		selected_sprite = null  # Deselect the sprite
		is_moving = false
		BebG_sprite_real.position = BebG_select_shadow.position
		print("Sprite placed at new position")
