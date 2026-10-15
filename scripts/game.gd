extends Node2D
## Composition root. Encounter progression, persistence and game-wide feedback.
const PlayerScene = preload("res://scenes/player.tscn")
const EnemyScene = preload("res://scenes/enemy.tscn")
const ProjectileScene = preload("res://scenes/projectile.tscn")
const ForestScript = preload("res://scripts/forest.gd")
const FXScript = preload("res://scripts/fx.gd")
const AudioScript = preload("res://scripts/audio.gd")
const HUDScript = preload("res://scripts/hud.gd")
var player: CharacterBody2D
var boss: CharacterBody2D
var world: Node2D
var fx: Node2D
var audio: Node
var camera: Camera2D
var hud: Control
var mode := "title"
var active := false
var wave := 0
var kills := 0
var elapsed := 0.0
var shake := 0.0
var hit_stop := 0.0
var red_flash := 0.0
var banner_text := ""
var banner_time := 0.0
var hazards: Array[Dictionary] = []
var pickups: Array[Dictionary] = []
var between := 0.0
var best := 0.0
var started := false
var rng := RandomNumberGenerator.new()
var auto_mode := false
var auto_clock := 0.0
var overlay: Node2D
var closing := false

func _ready() -> void:
	get_tree().auto_accept_quit = false
	get_window().close_requested.connect(shutdown)
	configure_inputs()
	rng.seed = 1973
	load_progress()
	world = Node2D.new()
	world.y_sort_enabled = true
	add_child(world)
	var forest := Node2D.new()
	forest.set_script(ForestScript)
	world.add_child(forest)
	fx = Node2D.new()
	fx.set_script(FXScript)
	fx.z_index = 30
	add_child(fx)
	audio = Node.new()
	audio.set_script(AudioScript)
	add_child(audio)
	player = PlayerScene.instantiate()
	player.game = self
	player.position = Vector2(550,430)
	world.add_child(player)
	camera = Camera2D.new()
	camera.position = Vector2(550,350)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 1100
	camera.limit_bottom = 770
	add_child(camera)
	var layer := CanvasLayer.new()
	add_child(layer)
	var atmosphere := Control.new()
	atmosphere.set_script(load("res://scripts/atmosphere.gd"))
	layer.add_child(atmosphere)
	hud = Control.new()
	hud.set_script(HUDScript)
	hud.game = self
	layer.add_child(hud)
	auto_mode = "--smoke" in OS.get_cmdline_user_args()
	if auto_mode: start_run()
	if "--capture" in OS.get_cmdline_user_args(): capture_sequence()
	queue_redraw()

func capture_sequence() -> void:
	await get_tree().create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://verification/title.png")
	start_run()
	await get_tree().create_timer(2.0).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://verification/combat.png")
	for e in get_tree().get_nodes_in_group("enemies"): e.queue_free()
	player.position = Vector2(550,425)
	player.invulnerable = 100
	boss = spawn_enemy(3,Vector2(550,280))
	wave = 4
	await get_tree().create_timer(5).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://verification/boss.png")
	boss.hp = 500
	boss.state = "approach"
	await get_tree().create_timer(2.5).timeout
	boss.state = "barrage"
	boss.timer = 3
	player.position = boss.position+Vector2(50,80)
	player.face = Vector2.UP
	await get_tree().create_timer(.8).timeout
	player.attack()
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://verification/awakened.png")
	shutdown()

func shutdown(exit_code := 0) -> void:
	if closing: return
	closing = true
	active = false
	Engine.time_scale = 1
	audio.stop_all()
	await get_tree().create_timer(.2).timeout
	get_tree().quit(exit_code)

func configure_inputs() -> void:
	var bindings := {"move_left":[KEY_A,KEY_LEFT],"move_right":[KEY_D,KEY_RIGHT],"move_up":[KEY_W,KEY_UP],"move_down":[KEY_S,KEY_DOWN],"attack":[KEY_J],"roll":[KEY_SPACE],"special":[KEY_K]}
	for action in bindings:
		if not InputMap.has_action(action): InputMap.add_action(action)
		for key in bindings[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			if not InputMap.action_has_event(action,ev): InputMap.action_add_event(action,ev)
	for action in ["attack","special"]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT if action=="attack" else MOUSE_BUTTON_RIGHT
		if not InputMap.action_has_event(action,ev): InputMap.action_add_event(action,ev)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	match event.physical_keycode:
		KEY_ENTER:
			if mode=="title": start_run()
			elif mode in ["won","lost"]: restart()
		KEY_R:
			if mode in ["won","lost","pause"]: restart()
		KEY_ESCAPE:
			if mode=="play":
				mode = "pause"
				active = false
			elif mode=="pause":
				mode = "play"
				active = true
		KEY_M: audio.toggle()
		KEY_1,KEY_2,KEY_3:
			if mode=="upgrade": choose_upgrade(event.physical_keycode-KEY_1)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		var at: Vector2 = event.position
		if mode=="title" and Rect2(35,211,270,66).has_point(at): start_run()
		elif mode=="upgrade" and at.x>130 and at.x<510 and at.y>145 and at.y<238:
			choose_upgrade(clampi(int((at.y-145)/29),0,2))

func start_run() -> void:
	mode = "play"
	active = true
	started = true
	next_wave()
	banner("KEEP THE MOONWELL ALIGHT",3)

func restart() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()

func next_wave() -> void:
	wave += 1
	if wave<=3:
		banner(["","I  /  WHISPERS IN THE MOSS","II  /  WINGS OF THE ECLIPSE","III  /  THE BRAMBLE HUNT"][wave],3)
		var types: Array = [[0,0,0,0],[0,0,1,1,2],[0,1,1,2,2,0]][wave-1]
		for i in range(types.size()):
			var angle := i*TAU/types.size()-.6
			spawn_enemy(types[i],Vector2(550,385)+Vector2.from_angle(angle)*235)
	else:
		boss = spawn_enemy(3,Vector2(550,235))
		banner("THE ECLIPSE HART",3)
		audio.sfx("chime",.6)

func spawn_enemy(kind: int, at: Vector2) -> CharacterBody2D:
	var e: CharacterBody2D = EnemyScene.instantiate()
	e.game = self
	e.kind = kind
	e.position = at.clamp(Vector2(85,100),Vector2(1015,675))
	world.add_child(e)
	fx.ring(e.position,35,Color("c5b1da"),.7)
	return e

func enemy_killed(e: CharacterBody2D) -> void:
	kills += 1
	if e.kind==3:
		finish(true)
	else:
		pickups.append({"p":e.position,"t":18.0})
		if get_tree().get_nodes_in_group("enemies").is_empty(): between = 1.5

func choose_upgrade(choice: int) -> void:
	match choice:
		0: player.damage *= 1.25
		1:
			player.max_hp += 25
			player.hp += 25
		2:
			player.speed *= 1.12
			player.focus = minf(100,player.focus+40)
	player.hp = minf(player.max_hp,player.hp+25)
	mode = "play"
	active = true
	audio.sfx("chime")
	next_wave()

func projectile(at: Vector2, velocity: Vector2, damage: float, color: Color) -> void:
	var p: Node2D = ProjectileScene.instantiate()
	p.game = self
	p.position = at
	p.velocity = velocity
	p.damage = damage
	p.tint = color
	add_child(p)

func clear_projectiles() -> void:
	for p in get_tree().get_nodes_in_group("projectiles"): p.queue_free()
	hazards.clear()

func hazard(at: Vector2, radius: float, delay: float) -> void:
	hazards.append({"p":at,"r":radius,"t":delay,"triggered":false})

func banner(message: String, duration: float) -> void:
	banner_text = message
	banner_time = duration

func finish(won: bool) -> void:
	mode = "won" if won else "lost"
	active = false
	clear_projectiles()
	if won:
		audio.sfx("chime")
		if best<=0 or elapsed<best:
			best = elapsed
			var config := ConfigFile.new()
			config.set_value("progress","best_seconds",best)
			config.save("user://progress.cfg")
	Engine.time_scale = 1

func load_progress() -> void:
	var config := ConfigFile.new()
	if config.load("user://progress.cfg")==OK: best = float(config.get_value("progress","best_seconds",0))

func best_text() -> String:
	return "%02d:%02d" % [int(best)/60,int(best)%60] if best>0 else "--:--"

func _process(dt: float) -> void:
	# Realtime counter keeps hit-stop duration independent of time dilation.
	var real_dt := dt/maxf(.01,Engine.time_scale)
	hit_stop = maxf(0,hit_stop-real_dt)
	Engine.time_scale = .12 if hit_stop>0 and active else 1.0
	shake = maxf(0,shake-real_dt*20)
	red_flash = maxf(0,red_flash-real_dt)
	banner_time = maxf(0,banner_time-dt)
	var target: Vector2 = player.position+player.face*18 if started else Vector2(585,350)
	if is_instance_valid(boss) and active:
		target = player.position+((boss.position+Vector2(0,-35))-player.position).limit_length(230)*.4
	camera.position = camera.position.lerp(target,1-exp(-dt*4))
	camera.offset = Vector2(rng.randf_range(-shake,shake),rng.randf_range(-shake,shake)).round()
	if active:
		elapsed += dt
		if between>0:
			between -= dt
			if between<=0:
				mode = "upgrade"
				active = false
				clear_projectiles()
		for h in hazards:
			h.t -= dt
			if h.t<=0 and not h.triggered:
				h.triggered = true
				fx.ring(h.p,h.r,Color("e7a6cb"),.5)
				fx.burst(h.p,Color("c7a9e2"),24,150)
				if player.position.distance_to(h.p)<h.r: player.hurt(24,h.p)
				shake = 5
		hazards = hazards.filter(func(h): return h.t>-.5)
		for drop in pickups:
			drop.t -= dt
			var distance: float = drop.p.distance_to(player.position)
			if distance<70: drop.p = drop.p.move_toward(player.position,dt*150)
			if distance<13:
				player.hp = minf(player.max_hp,player.hp+6)
				player.focus = minf(100,player.focus+8)
				drop.t = 0
				audio.sfx("chime",1.5)
		pickups = pickups.filter(func(d): return d.t>0)
	if auto_mode: smoke_tick(real_dt)
	queue_redraw()

func _draw() -> void:
	for h in hazards:
		if not h.triggered:
			draw_circle(h.p,h.r,Color("d99bd4",.12))
			draw_arc(h.p,h.r,0,TAU,48,Color("f5b0d1"),2)
	for drop in pickups:
		var p: Vector2 = drop.p+Vector2(0,sin(elapsed*4)*2-5)
		draw_circle(p,8,Color("a4eed2",.1))
		draw_colored_polygon(PackedVector2Array([p+Vector2(0,-4),p+Vector2(3,0),p+Vector2(0,4),p+Vector2(-3,0)]),Color("c7f1ca"))

func smoke_tick(dt: float) -> void:
	# Integration harness uses actual runtime objects. Disabled in normal play.
	auto_clock += dt
	player.invulnerable = 1
	if mode=="upgrade": choose_upgrade(0)
	if int(auto_clock*3)!=int((auto_clock-dt)*3) and active:
		var enemies := get_tree().get_nodes_in_group("enemies")
		if not enemies.is_empty():
			var e = enemies[0]
			player.position = e.position+Vector2(24,0)
			player.face = Vector2.LEFT
			player.attack()
	if auto_clock>45:
		print("SMOKE: mode=",mode," wave=",wave," kills=",kills," boss_phase=",boss.phase if is_instance_valid(boss) else -1)
		shutdown(0 if mode=="won" else 1)
