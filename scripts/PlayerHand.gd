extends Node2D

const CARD_WIDTH = 70
const UP_HAND_Y_POS = 320.0
const DOWN_HAND_Y_POS = 330.0
const DEFAULT_DRAW_SPEED = 0.3 

var player_hand = []
var center_screen_x
var hovered_on
var card_manager_ref

func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	hovered_on = false
	card_manager_ref = $"../CardManager"
	
func add_card_to_hand(card, speed):
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.hand_pos, speed)
	
func update_hand_positions(speed):
	for i in range(player_hand.size()):
		# Get new card position based on index
		var new_position = calculate_card_position(i)
		var card = player_hand[i]
		card.hand_pos = new_position
		animate_card_to_position(card, new_position, speed)
		
func calculate_card_position(index):
	var x_offset = (player_hand.size() - 1) * CARD_WIDTH
	var x_position = center_screen_x + index * CARD_WIDTH - x_offset / 2
	var y_position
	if hovered_on:
		y_position = UP_HAND_Y_POS
	elif not hovered_on:
		y_position = DOWN_HAND_Y_POS
	else:
		print("Conditional Execution Failure")
	return Vector2(x_position, y_position)

func animate_card_to_position(card, pos, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", pos, speed)

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions(DEFAULT_DRAW_SPEED)

func _on_area_2d_mouse_entered():
	if not hovered_on and not card_manager_ref.card_being_dragged:
		hovered_on = true
		$Area2D/CollisionShape2D.position = Vector2(center_screen_x, UP_HAND_Y_POS)
		update_hand_positions(DEFAULT_DRAW_SPEED)
	
func _on_area_2d_mouse_exited():
	if hovered_on and not card_manager_ref.card_being_dragged:
		hovered_on = false
		$Area2D/CollisionShape2D.position = Vector2(center_screen_x, DOWN_HAND_Y_POS+30)
		update_hand_positions(DEFAULT_DRAW_SPEED)
	
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
