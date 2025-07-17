extends Node2D

const CARD_SCENE_PATH = "res://scenes/card.tscn"
const CARD_DRAW_SPEED = 0.4

var player_deck = ['SecurityG','SecurityG','TEMP_CARD','TEMP_CARD']
var card_DB_ref
# Called when the node enters the scene tree for the first time.
func _ready():
	player_deck.shuffle()
	$Count.text = str(player_deck.size())
	card_DB_ref = preload("res://scripts/CardDatabase.gd")
	
func draw_card():
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	$Count.text = str(player_deck.size())
	if player_deck.size() == 0: # Disable the deck when the last card is drawn.
		$Area2D/CollisionShape2D.disabled = true
		$DeckSprite.visible = false
		$Count.visible = false
	
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_img_path = str("res://assets/art/" + card_drawn + ".png")
	new_card.get_node("Illustration").texture = load(card_img_path)
	new_card.get_node("AttackText").text = "ATK: " + str(card_DB_ref.CARDS[card_drawn][0])
	new_card.get_node("HealthText").text = "HP: " + str(card_DB_ref.CARDS[card_drawn][1])
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
	new_card.get_node("AnimationPlayer").play("card_flip")
