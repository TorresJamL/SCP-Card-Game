extends Node2D

const COLLISON_MASK_CARD = 1
const COLLISON_MASK_CARD_SLOT = 2
const BASE_SCALE = 1
const GREATER_SCALE = BASE_SCALE + 0.05

var screen_size # Should be settable in options
var card_being_dragged
var is_hovering_on_card
var player_hand_ref

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	player_hand_ref = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_button_released", on_left_mb_release)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), clamp(mouse_pos.y, 0, screen_size.y))

func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(GREATER_SCALE, GREATER_SCALE)

func finish_drag():
	card_being_dragged.scale = Vector2(BASE_SCALE, BASE_SCALE)
	var card_slot_found = raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_in_slot:
		player_hand_ref.remove_card_from_hand(card_being_dragged)
		# Card dropped in empty card slot
		card_being_dragged.position = card_slot_found.position
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
		card_slot_found.card_in_slot = true
	else:
		player_hand_ref.add_card_to_hand(card_being_dragged, player_hand_ref.DEFAULT_DRAW_SPEED)
	card_being_dragged = null

func connect_card_signals(card):
	card.connect("hovered", on_hover_over_card)
	card.connect("hovered_off", on_hover_off_card)
	
func on_left_mb_release():
	if card_being_dragged:
		finish_drag()

func on_hover_over_card(card):
	if !is_hovering_on_card: 
		highligt_card(card, true)
		is_hovering_on_card = true
	
func on_hover_off_card(card):
	if !card_being_dragged:
		highligt_card(card, false)
		# check if we've hovered off one card and straight onto another card
		var new_card_hovered = raycast_check_for_cards()
		if new_card_hovered: ###! FOCUS POINT
			highligt_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false

func highligt_card(card, hovered:bool):
	if hovered:
		card.scale = Vector2(GREATER_SCALE, GREATER_SCALE)
		card.z_index = 2
	else:
		card.scale = Vector2(BASE_SCALE, BASE_SCALE)
		card.z_index = 1

func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISON_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func raycast_check_for_cards():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISON_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		#return result[0].collider.get_parent()
		return get_card_with_highest_z_index(result)
	return null

func get_card_with_highest_z_index(cards):
	# Assume the first card passed in has the highest Z-index
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	# Loop through the rest of the cards checking for a higher z index
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card
		
	
