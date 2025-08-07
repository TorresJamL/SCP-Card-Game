extends Node2D

const CARD_WIDTH = 60
const CARD_HEIGHT = 10
const UP_HAND_Y_POS = 320.0
const DOWN_HAND_Y_POS = 330.0
const DEFAULT_DRAW_SPEED = 0.3 
const HAND_POS_UPD_SPEED = DEFAULT_DRAW_SPEED - 0.15

@export var curve_width: Curve
@export var curve_height: Curve
@export var curve_rotation: Curve

var player_hand = []
var center_screen_x
var hovering
var card_manager_ref

func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	hovering = false
	card_manager_ref = $"../CardManager"
	
func add_card_to_hand(card, speed):
	if card not in player_hand:
		player_hand.insert(player_hand.size() / 2, card)
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.hand_pos, speed)
	
func update_hand_positions(speed, adjust_fanning := true):
	var hand_size = player_hand.size() 
	for i in range(hand_size):
		# Get new card position based on index
		### _
		#var new_position = calculate_card_position(i)
		#var card = player_hand[i]
		#card.hand_pos = new_position # Player hand is somehow adding itself to the card list causing an error.
		#animate_card_to_position(card, new_position, speed)
		### _
		var card = player_hand[i]
		var hand_ratio = 0.5
		var rot_multiplier
		if hand_size > 1:
			hand_ratio = float(i / float(hand_size - 1))
			rot_multiplier = curve_rotation.sample(1.0 / (hand_size - 1) * i)
		else:
			rot_multiplier = 0
		var destination = calculate_card_position(i)
		if adjust_fanning:
			destination.x += curve_width.sample(hand_ratio)
			destination.y -= curve_height.sample(hand_ratio)
			card.global_rotation_degrees = null
		card.hand_pos = Vector2(destination.x, destination.y)
		animate_card_to_position(card, card.hand_pos, speed)
		
func calculate_card_position(index):
	var x_offset = (player_hand.size() - 1) * CARD_WIDTH
	var x_position = center_screen_x + index * CARD_WIDTH - x_offset / 2
	var y_position
	if hovering:
		y_position = UP_HAND_Y_POS
	elif not hovering:
		y_position = DOWN_HAND_Y_POS
	else:
		print("Conditional Execution Failure")
	var y_offset = index * CARD_HEIGHT
	return Vector2(x_position, y_position)

func calculate_card_rotation_deg(index):
	pass

func animate_card_to_position(card, pos, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", pos, speed)

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions(DEFAULT_DRAW_SPEED)

func _on_area_2d_mouse_entered():
	if not hovering and not card_manager_ref.card_being_dragged:
		hovering = true
		$Area2D/CollisionShape2D.position = Vector2(center_screen_x, UP_HAND_Y_POS)
		update_hand_positions(HAND_POS_UPD_SPEED, false)
	
func _on_area_2d_mouse_exited():
	if hovering and not card_manager_ref.card_being_dragged:
		hovering = false
		$Area2D/CollisionShape2D.position = Vector2(center_screen_x, DOWN_HAND_Y_POS+30)
		update_hand_positions(HAND_POS_UPD_SPEED,false)
	
func debug_info(message = ""):
	print("DEBUG INFO | PLAYER_HAND | " + message 
	+ "\nCollision Area Position Property: " + str($Area2D/CollisionShape2D.position)
	+ "\nCollision Scale Property: " + str($Area2D/CollisionShape2D.scale)
	+ "\nCollision Shape Property: " + str($Area2D/CollisionShape2D.shape)
	+ "\nCollision Global Pos: " + str($Area2D/CollisionShape2D.global_position)
	+ "\nArea Position Property:" + str($Area2D.position)
	+ "\nArea Scale Property: " + str($Area2D.scale)
	+ "\nArea Global Pos: " + str($Area2D.global_position)
	+ "\nPlayer Hand Pos: " + str($".".position)
	+ "\nPlayer Global Hand Pos: " + str($".".global_position)
	+ "\nmain node2D: " + str($"..".position)
	+ "\n|<--------------------------------------->|")
