extends CharacterBody2D

var enemy_in_attack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_is_alive = true
var can_take_damage = true
var attack_power = 20
var combat_name = "Joueur"

var attack_ip = false
var current_enemy: Node2D = null
var combat_started = false

const speed = 100
var current_dir = "none"

func _ready():
	$AnimatedSprite2D.play("front_idle")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			# Start combat if near enemy
			if current_enemy != null and not combat_started:
				combat_started = true
				Global.start_combat(self, current_enemy)
			# Otherwise, do a normal attack
			else:
				attack_action()
			get_tree().get_root().set_input_as_handled()

func attack_action():
	var dir = current_dir
	Global.player_current_attack = true
	attack_ip = true
	if dir=="right":
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("side_attack")
		$deal_attack_timer.start()
	if dir=="left":
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("side_attack")
		$deal_attack_timer.start()
	if dir=="down":
		$AnimatedSprite2D.play("front_attack")
		$deal_attack_timer.start()
	if dir=="up":
		$AnimatedSprite2D.play("back_attack")
		$deal_attack_timer.start()



func _physics_process(delta):
	player_movement(delta)
	enemy_attack()
	current_camera()
	
	if health<=0:
		player_is_alive = false #add end screen
		health = 0
		print("Player has been killed")
		self.queue_free()

func player_movement(delta):
	
	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_anim(1)
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		play_anim(1)
		velocity.x = 0
		velocity.y = speed
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		play_anim(1)
		velocity.x = 0
		velocity.y = -speed
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0
	
	move_and_slide()

func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("side_idle")
	elif dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("side_idle")
	elif dir == "down":
		anim.flip_h = true
		if movement == 1:
			anim.play("front_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("front_idle")
	elif dir == "up":
		anim.flip_h = true
		if movement == 1:
			anim.play("back_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("back_idle")

func player():
	pass

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_attack_range = true
		current_enemy = body


func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_attack_range = false
		if body == current_enemy:
			current_enemy = null

func enemy_attack():
	if enemy_in_attack_range and enemy_attack_cooldown and current_enemy != null and not combat_started:
		enemy_attack_cooldown = false
		combat_started = true
		$attack_cooldown.start()
		Global.start_combat(self, current_enemy)


func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true

func _on_deal_attack_timer_timeout() -> void:
	$deal_attack_timer.stop()
	Global.player_current_attack = false
	attack_ip = false

func current_camera():
	if Global.current_scene == "world":
		$world_camera.enabled = true
		$northworld_camera.enabled = false
	elif Global.current_scene == "northworld":
		$northworld_camera.enabled = true
		$world_camera.enabled = false
