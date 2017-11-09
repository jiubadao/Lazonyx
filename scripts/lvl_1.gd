extends Node

#children
onready var enemy_spawner = get_node("enemy_spawner")
onready var player        = get_node("player")

#game
var start_time = OS.get_unix_time()
var game_time = start_time
var time_to_spawn_enemy = 1.0

#enemies
var number_of_enemies = 0
var max_number_of_enemies = 5
var time_between_enemy_spawns = 1.0

#player
var player_lives = 3
var current_score = 0
var points_per_goal = 1

func _ready():
	player.connect("entered_goal", self, "_player_entered_goal")
	set_process(true)
	pass

func _process(delta):
	# calculate game time
	game_time = OS.get_unix_time() - start_time
	if game_time >= time_to_spawn_enemy:
		attempt_spawn_enemy()
	time_to_spawn_enemy = game_time + time_between_enemy_spawns
	pass

func enemy_died(death_position, death_velocity):
	var new_orb = file_manager.ORB_PREFAB.instance()
	new_orb.set_pos(death_position)
	new_orb.set_linear_velocity(death_velocity)
	new_orb.connect("entered_goal", self, "_orb_entered_goal")
	add_child(new_orb)
	number_of_enemies -= 1
	
	
func _orb_entered_goal(orb, goal):
	if orb.target_goal == goal.get_name():
		current_score += points_per_goal
	print(current_score)
	orb.queue_free()
	
func _enemy_entered_goal(enemy):
	enemy.set_pos(enemy_spawner.get_pos())
	
func _player_entered_goal(player):
	deduct_life()
	reset_player_position()
	
func reset_player_position():
	player.set_pos(enemy_spawner.get_pos())
	player.body.set_pos(Vector2(0,0))
	player.body.set_linear_velocity(Vector2(0,0))

func find_scene_node(name):
	get_node(name)
	
func attempt_spawn_enemy():
	if number_of_enemies < max_number_of_enemies:
		var new_enemy = enemy_spawner.spawn_enemy()
		new_enemy.connect("entered_goal", self, "_enemy_entered_goal")
		number_of_enemies += 1

func deduct_life():
	player_lives -= 1
	if player_lives < 1:
		game_over()

func enemy_hit_player():
	deduct_life()
		

func game_over():
	print("game_over")
