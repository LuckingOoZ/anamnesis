extends Node

var player_current_attack = false

var current_scene = "world" #world/northworld/eastworld
var transition_scene = false

var player_exit_northworld_posx = 127
var player_exit_northworld_posy = 25
var player_start_posx = 42
var player_start_posy = 121

var game_first_loading = true


func finish_changing_scene():
	if transition_scene == true:
		transition_scene = false
		if current_scene == "world":
			current_scene = "northworld"
		else:
			current_scene = "world"
