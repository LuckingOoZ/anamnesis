extends Node

var player_current_attack = false

var current_scene = "world" #world/northworld/eastworld
var transition_scene = false

var player_exit_northworld_posx = 127
var player_exit_northworld_posy = 25
var player_start_posx = 42
var player_start_posy = 121

var game_first_loading = true
var pending_player_data: CharacterData = null
var pending_enemy_data: CharacterData = null
var combat_scene_path = "res://scenes/CombatPrincipal.tscn"

# Position sauvegardée avant le combat
var saved_player_position: Vector2 = Vector2.ZERO
var combat_won = false
var defeated_enemy_node: Node = null


func finish_changing_scene():
	if transition_scene == true:
		transition_scene = false
		if current_scene == "world":
			current_scene = "northworld"
		else:
			current_scene = "world"


func change_scene():
	if not transition_scene:
		return

	if current_scene == "world":
		get_tree().change_scene_to_file("res://scenes/northworld.tscn")
		current_scene = "northworld"
	elif current_scene == "northworld":
		get_tree().change_scene_to_file("res://scenes/world.tscn")
		current_scene = "world"

	transition_scene = false


func start_combat(player_node: Node, enemy_node: Node) -> void:
	if player_node == null or enemy_node == null:
		return

	# Save player position and enemy reference before combat
	saved_player_position = player_node.position
	defeated_enemy_node = enemy_node
	combat_won = false

	var player_data := CharacterData.new()
	player_data.name = player_node.combat_name
	player_data.max_hp = player_node.health
	player_data.attack = player_node.attack_power

	var enemy_data := CharacterData.new()
	enemy_data.name = enemy_node.combat_name
	enemy_data.max_hp = enemy_node.health
	enemy_data.attack = enemy_node.attack_power

	pending_player_data = player_data
	pending_enemy_data = enemy_data

	get_tree().change_scene_to_file(combat_scene_path)
