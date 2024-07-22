extends Control

@onready var CursorNode = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_attack_button_pressed():
	print("attack")


func _on_items_pressed():
	pass # Replace with function body.


func _on_wait_pressed():
	CursorNode.place_sprite()
