extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.game_first_loading == true:
		$player.position.x = Global.player_start_posx
		$player.position.y = Global.player_start_posy
	else:
		$player.position.x = Global.player_exit_northworld_posx
		$player.position.y = Global.player_exit_northworld_posy
	
	# Restore position after combat if won
	if Global.combat_won:
		$player.position = Global.saved_player_position
		# Remove defeated enemy
		if Global.defeated_enemy_node != null and not Global.defeated_enemy_node.is_queued_for_deletion():
			Global.defeated_enemy_node.queue_free()
	
	# Re-enable player cameras
	if $player.has_node("world_camera"):
		$player.get_node("world_camera").enabled = true
	if $player.has_node("northworld_camera"):
		$player.get_node("northworld_camera").enabled = false
	
	# Reset combat flag
	$player.combat_started = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	Global.change_scene()


func _on_northworld_transition_point_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		Global.transition_scene = true


func _on_northworld_transition_point_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		Global.transition_scene = false
