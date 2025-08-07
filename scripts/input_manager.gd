extends Node2D
signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISON_MASK_CARD = 1
const COLLISON_MASK_DECK = 4

var player_hand_ref
var card_manager_ref
var deck_ref

func _ready() -> void:
	player_hand_ref = $"../PlayerHand"
	card_manager_ref = $"../CardManager"
	deck_ref = $"../Deck"

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			emit_signal("left_mouse_button_clicked")
			raycast_at_cursor()
		else:
			emit_signal("left_mouse_button_released")

func raycast_at_cursor():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var results = space_state.intersect_point(parameters)
	### Different Approach |>
	for result in results:
		var result_collision_mask = result.collider.collision_mask
		match result_collision_mask:
			COLLISON_MASK_CARD:
				var card_found = result.collider.get_parent()
				if card_found and player_hand_ref.hovering: card_manager_ref.start_drag(card_found)
				break;
			COLLISON_MASK_DECK:
				deck_ref.draw_card()
				break;
			_:
				print("DefaultCase: " + str(result_collision_mask))
				continue;
	### |<
	#if results.size() > 0:
		#print("Resulting Collision Mask: " + str(results[0]))
		#var result_collision_mask = results[0].collider.collision_mask
		#if result_collision_mask == 32 and results.size() > 1:
			#result_collision_mask = results[1].collider.collision_mask
			#print("New Resulting Collision Mask: " + str(result_collision_mask))
			#print("Collider Parent: " + str(results[1].collider.parent))
		#if result_collision_mask == COLLISON_MASK_CARD:
			#var card_found = results[0].collider.get_parent()
			#if card_found:
				#print("Card Found: " + str(card_found))
				#card_manager_ref.start_drag(card_found)
		#elif result_collision_mask == COLLISON_MASK_DECK:
			## Deck clicked
			#deck_ref.draw_card()
		#else:
			#print("else_proc: " + str(result_collision_mask))
