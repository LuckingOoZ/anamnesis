extends Node2D


@onready var enemy_pos =$Positions/EnemyPos
@onready var action_menu =$CombatUI/ActionMenu
@onready var battle_log =$CombatUI/BattleLog

# Var combats
var player_stats: Dictionary
var enemy_stats: Dictionary

enum Turn{PLAYER, ENEMY, CHECK_WIN}
var current_turn = Turn.PLAYER

func _ready():
	setup_combat(player_data, enemy_data)


func setup_combat(player: CharacterData, enemy:CharacterData):
	player_stats={"name":player.name, "hp":player.max_hp, "atk":player.attack}
	enemy_stats={"name":enemy.name, "hp":enemy.max_hp, "atk":enemy.attack}
	
	var enemy_sprite = Sprite2D.new()
	enemy_sprite.texture = enemy.texture
	enemy_pos.add_child(enemy_sprite)
	
	battle_log.text = "Un %s approche !" % enemy_stats.name
	start_player_turn()


func start_player_turn():
	current_turn = Turn.PLAYER
	action_menu.show()
	battle_log.text = "A votre tour !"

func _on_attack_button_pressed(): #bouton attack
	action_menu.hide()
	
	enemy_stats.hp -= player_stats.atk
	battle_log.text = "Vous infligez %d dégats au %s !" % [player_stats.atk, enemy_stats.name]
	
	await get_tree().create_timer(1.5).timeout
	check_battle_status(Turn.ENEMY)

func start_enemy_turn():
	current_turn = Turn.ENEMY
	battle_log.text = "%s attaque !" % enemy_stats.name
	await get_tree().create_timer(1.0).timeout
	
	player_stats.hp -= enemy_stats.atk
	battle_log.text = "%s vous inflige %d dégats !" % [enemy_stats.name, enemy_stats.atk]
	
	await get_tree().create_timer(1.5).timeout
	check_battle_status(Turn.PLAYER)

func check_battle_status(next_turn):
	if enemy_stats.hp<=0:
		battle_log.text = "Victoire !"
		# à mettre xp et retour map
	elif player_stats.hp<=0:
		battle_log.text = "Défaite..."
		# à mettre écran gameover
	else:
		if next_turn==Turn.PLAYER:
			start_player_turn()
		else:
			start_enemy_turn()
