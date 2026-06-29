extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Re-enable player cameras
	if has_node("player"):
		if $player.has_node("world_camera"):
			$player.get_node("world_camera").enabled = false
		if $player.has_node("northworld_camera"):
			$player.get_node("northworld_camera").enabled = true
		
		# Restore position after combat if won
		if Global.combat_won:
			$player.position = Global.saved_player_position
			# Remove defeated enemy
			if Global.defeated_enemy_node != null and not Global.defeated_enemy_node.is_queued_for_deletion():
				Global.defeated_enemy_node.queue_free()
		
		# Reset combat flag
		$player.combat_started = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	Global.change_scene()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		Global.transition_scene = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		Global.transition_scene = false
