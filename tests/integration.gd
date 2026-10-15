extends Node
## Run: godot --headless --path . tests/integration.tscn
var game: Node2D
var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("FAIL: "+message)
	else: print("PASS: "+message)

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	game._unhandled_key_input(event)

func _ready() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	add_child(game)
	await wait(.1)
	check(game.mode=="title" and not game.active,"title state")
	key(KEY_ENTER)
	check(game.active and game.wave==1,"Enter starts first encounter")
	var start: Vector2 = game.player.position
	Input.action_press("move_right")
	await wait(.2)
	Input.action_release("move_right")
	check(game.player.position.x>start.x+10,"actual movement input")
	Input.action_press("roll")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release("roll")
	check(game.player.roll_time>0 and game.player.stamina<80,"dodge spends stamina")
	var hp: float = game.player.hp
	game.player.hurt(30,game.player.position-Vector2(10,0))
	check(game.player.hp==hp,"dodge has invulnerability")
	await wait(.4)
	game.player.invulnerable = 0
	game.player.hurt(10,game.player.position-Vector2(10,0))
	check(game.player.hp==hp-10,"unprotected damage")
	key(KEY_ESCAPE)
	var frozen: Vector2 = game.player.position
	Input.action_press("move_down")
	await wait(.2)
	Input.action_release("move_down")
	check(not game.active and game.player.position==frozen,"pause freezes gameplay")
	key(KEY_ESCAPE)
	check(game.active,"pause resumes")
	game.player.position = Vector2(238,240)
	Input.action_press("move_right")
	await wait(.25)
	Input.action_release("move_right")
	check(game.player.position.x<248,"stone collision blocks movement")
	game.player.position = Vector2(550,430)
	for e in get_tree().get_nodes_in_group("enemies"): e.queue_free()
	await get_tree().process_frame
	var e = game.spawn_enemy(0,game.player.position+Vector2(23,0))
	game.player.face = Vector2.RIGHT
	game.player.attack()
	check(e.hp<e.max_hp,"claw arc hits nearby enemy")
	game.player.attack()
	game.player.attack()
	check(game.player.combo==2,"three-step combo")
	await wait(.45)
	var target = game.spawn_enemy(2,game.player.position+Vector2(70,0))
	var target_hp: float = target.hp
	game.player.focus = 100
	Input.action_press("special")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release("special")
	check(target.hp<target_hp and game.player.focus==0,"charged moonburst consumes focus and damages area")
	for kind in [0,1,2]:
		var foe = game.spawn_enemy(kind,Vector2(780,450))
		foe.state = "windup"
		foe.timer = .01
		foe.locked = Vector2.LEFT
		await wait(.05)
		check(foe.state==("recover" if kind==1 else "charge"),"enemy %d windup resolves distinct attack" % kind)
		foe.queue_free()
	game.clear_projectiles()
	game.player.roll_time = .2
	game.player.invulnerable = .3
	var focus_before: float = game.player.focus
	game.projectile(game.player.position,Vector2.ZERO,10,Color.WHITE)
	await wait(.05)
	check(game.player.focus>focus_before,"dodging a projectile rewards focus")
	game.mode = "upgrade"
	game.active = false
	game.between = 0
	var old_damage: float = game.player.damage
	key(KEY_1)
	check(game.player.damage>old_damage and game.active and game.wave==2,"upgrade selection and next wave")
	for foe in get_tree().get_nodes_in_group("enemies"): foe.queue_free()
	await get_tree().process_frame
	game.boss = game.spawn_enemy(3,Vector2(550,280))
	game.boss.state = "approach"
	game.boss.hp = 500
	await get_tree().physics_frame
	await get_tree().physics_frame
	check(game.boss.phase==2 and game.boss.state=="transition","boss phase at half health")
	await wait(2.5)
	game.boss.state = "barrage"
	game.boss.timer = 1
	game.boss.shot_clock = 0
	await wait(.1)
	check(get_tree().get_nodes_in_group("projectiles").size()>=14,"awakened boss radial barrage")
	game.clear_projectiles()
	await get_tree().process_frame
	game.player.invulnerable = 0
	game.player.hp = 100
	game.hazard(game.player.position,50,.03)
	await wait(.1)
	check(game.player.hp<100,"ground hazard resolves damage")
	game.player.invulnerable = 0
	game.player.hurt(1000,Vector2.ZERO)
	check(game.mode=="lost" and not game.active,"failure state")
	game.active = true
	game.mode = "play"
	game.boss.state = "recover"
	game.boss.take_damage(9999,game.player.position,0)
	check(game.mode=="won" and not game.active,"boss death resolves victory")
	check(FileAccess.file_exists("user://progress.cfg"),"best-time persistence written")
	# Reload the same scene as the R handler does; ensure no stale nodes/state.
	game.queue_free()
	await get_tree().process_frame
	game = load("res://scenes/main.tscn").instantiate()
	add_child(game)
	await wait(.1)
	check(game.mode=="title" and game.kills==0 and game.player.hp==100,"fresh scene reset")
	check(game.best>0,"best time reload")
	print("INTEGRATION RESULT: ",failures," failures")
	game.audio.stop_all()
	await wait(.3)
	game.queue_free()
	await get_tree().process_frame
	get_tree().quit(0 if failures==0 else 1)
