extends Node2D


@onready var player_pos = $Positions/PlayerPos
@onready var enemy_pos = $Positions/EnemyPos
@onready var action_menu = $CombatUI/ActionMenu
@onready var battle_log = $CombatUI/BattleLog
@onready var combat_camera = $Camera2D

# Var combats
var player_stats: Dictionary
var enemy_stats: Dictionary

# Combat visual elements
var player_sprite: Sprite2D
var enemy_sprite: Sprite2D

enum Turn {PLAYER, ENEMY, CHECK_WIN}
var current_turn = Turn.PLAYER


func _ready():
	# Disable player cameras
	var player = get_tree().get_first_node_in_group("player")
	if player != null:
		if player.has_node("world_camera"):
			player.get_node("world_camera").enabled = false
		if player.has_node("northworld_camera"):
			player.get_node("northworld_camera").enabled = false
	
	# Setup combat camera as current
	if combat_camera != null:
		combat_camera.zoom = Vector2(0.5, 0.5)
		combat_camera.position = Vector2(320, 180)
		combat_camera.enabled = true
		# Give a small delay to ensure it's properly set
		await get_tree().process_frame
		combat_camera.make_current()
	
	if Global.pending_player_data != null and Global.pending_enemy_data != null:
		setup_combat(Global.pending_player_data, Global.pending_enemy_data)
	else:
		var fallback_player := CharacterData.new()
		fallback_player.name = "Joueur"
		fallback_player.max_hp = 100
		fallback_player.attack = 20

		var fallback_enemy := CharacterData.new()
		fallback_enemy.name = "Ennemi"
		fallback_enemy.max_hp = 100
		fallback_enemy.attack = 15
		setup_combat(fallback_player, fallback_enemy)


func setup_combat(player: CharacterData, enemy: CharacterData):
	player_stats = {"name": player.name, "hp": player.max_hp, "atk": player.attack}
	enemy_stats = {"name": enemy.name, "hp": enemy.max_hp, "atk": enemy.attack}

	# Cleanup existing sprites
	for child in player_pos.get_children():
		child.queue_free()
	for child in enemy_pos.get_children():
		child.queue_free()

	# Create player sprite with specific frame
	player_sprite = Sprite2D.new()
	var player_texture = load("res://art/sprites/characters/player.png")
	var player_atlas = AtlasTexture.new()
	player_atlas.atlas = player_texture
	player_atlas.region = Rect2(0, 0, 48, 48)  # Front idle first frame
	player_sprite.texture = player_atlas
	player_sprite.scale = Vector2(3, 3)
	player_sprite.offset = Vector2(0, -10)
	player_pos.add_child(player_sprite)

	# Create enemy sprite with specific frame
	enemy_sprite = Sprite2D.new()
	var enemy_texture = load("res://art/sprites/characters/slime.png")
	var enemy_atlas = AtlasTexture.new()
	enemy_atlas.atlas = enemy_texture
	enemy_atlas.region = Rect2(0, 0, 32, 32)  # First frame
	enemy_sprite.texture = enemy_atlas
	enemy_sprite.scale = Vector2(3, 3)
	enemy_sprite.offset = Vector2(0, -10)
	enemy_pos.add_child(enemy_sprite)

	battle_log.text = "Un %s approche !" % enemy_stats.name
	start_player_turn()


func start_player_turn():
	current_turn = Turn.PLAYER
	for child in action_menu.get_children():
		child.queue_free()

	var attack_button = Button.new()
	attack_button.text = "Attaquer"
	attack_button.pressed.connect(_on_attack_button_pressed)
	action_menu.add_child(attack_button)
	action_menu.show()
	battle_log.text = "À votre tour !"
	
	# Player idle visual feedback
	if player_sprite != null:
		player_sprite.modulate = Color.WHITE


func _on_attack_button_pressed():
	action_menu.hide()
	
	# Show player attack animation (flash effect)
	if player_sprite != null:
		var original_color = player_sprite.modulate
		player_sprite.modulate = Color.YELLOW
		await get_tree().create_timer(0.2).timeout
		player_sprite.modulate = original_color
	
	enemy_stats.hp -= player_stats.atk
	battle_log.text = "Vous infligez %d dégâts au %s !" % [player_stats.atk, enemy_stats.name]

	await get_tree().create_timer(1.5).timeout
	check_battle_status(Turn.ENEMY)


func start_enemy_turn():
	current_turn = Turn.ENEMY
	battle_log.text = "%s attaque !" % enemy_stats.name
	
	# Flash enemy red to show attack
	if enemy_sprite != null:
		var original_modulate = enemy_sprite.modulate
		enemy_sprite.modulate = Color.RED
		await get_tree().create_timer(0.3).timeout
		enemy_sprite.modulate = original_modulate
	
	await get_tree().create_timer(1.0).timeout

	player_stats.hp -= enemy_stats.atk
	battle_log.text = "%s vous inflige %d dégâts !" % [enemy_stats.name, enemy_stats.atk]

	await get_tree().create_timer(1.5).timeout
	check_battle_status(Turn.PLAYER)


func check_battle_status(next_turn):
	if enemy_stats.hp <= 0:
		battle_log.text = "Victoire !"
		if enemy_sprite != null:
			enemy_sprite.visible = false
		Global.combat_won = true
		await get_tree().create_timer(1.5).timeout
		return_to_map()
	elif player_stats.hp <= 0:
		battle_log.text = "Défaite..."
		if player_sprite != null:
			player_sprite.visible = false
		Global.combat_won = false
		await get_tree().create_timer(1.5).timeout
		return_to_map()
	else:
		if next_turn == Turn.PLAYER:
			start_player_turn()
		else:
			start_enemy_turn()


func return_to_map():
	var scene_path = "res://scenes/world.tscn"
	if Global.current_scene == "northworld":
		scene_path = "res://scenes/northworld.tscn"
	get_tree().change_scene_to_file(scene_path)
