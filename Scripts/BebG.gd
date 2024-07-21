extends CharacterBody2D

var tile_size = Vector2(32,32) 

# Define stats
var max_health = 100
var current_health: int = 100
var movement: int = 5
var attack: int = 10
var defense: int = 5
var attack_range: int = 32

# Health-related methods
func take_damage(damage: int):
	var actual_damage = damage - defense
	if actual_damage < 0:
		actual_damage = 0
	current_health -= actual_damage
	if current_health <= 0:
		die()

func heal(amount: int):
	current_health += amount
	if current_health > max_health:  # Assuming max health is 100
		current_health = 100

func die():
	queue_free()  # Remove the sprite from the scene

# Attack-related methods
func attack_target(target):
	if target and target.is_in_group("enemies"):
		target.take_damage(attack)

func is_on_same_tile(cba_pos: Vector2, sprite_pos: Vector2) -> bool:
	# Convert sprite position to tile coordinates and check if they match
	var sprite_tile_pos = sprite_pos / tile_size
	sprite_tile_pos = Vector2(round(sprite_tile_pos.x), round(sprite_tile_pos.y))
	var cba_tile_pos = cba_pos / tile_size
	cba_tile_pos = Vector2(round(cba_tile_pos.x), round(cba_tile_pos.y))
	return cba_tile_pos == sprite_tile_pos
