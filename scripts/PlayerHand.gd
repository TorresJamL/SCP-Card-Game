extends Node2D

const CARD_WIDTH = 70
const UP_HAND_Y_POS = 300.0
const DOWN_HAND_Y_POS = 330.0
const DEFAULT_DRAW_SPEED = 0.3 

var player_hand = []
var center_screen_x
var hovered_on

func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	hovered_on = false
	
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
	print("Entered area")
	if not hovered_on:
		print("Hovering")
		hovered_on = true
		$Area2D/CollisionShape2D.position.y = UP_HAND_Y_POS
	update_hand_positions(DEFAULT_DRAW_SPEED)
	
func _on_area_2d_mouse_exited():
	print("Exited area")
	if hovered_on:
		print("not Hover")
		hovered_on = false
		$Area2D/CollisionShape2D.position.y = DOWN_HAND_Y_POS
	update_hand_positions(DEFAULT_DRAW_SPEED)
