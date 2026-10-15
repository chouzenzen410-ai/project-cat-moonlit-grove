extends CharacterBody2D
## Input buffering, three-hit combo, coyote-free top-down dodge and arc hit tests.
signal health_changed
var game: Node2D
var hp := 100.0
var max_hp := 100.0
var stamina := 100.0
var focus := 0.0
var damage := 18.0
var speed := 108.0
var face := Vector2.RIGHT
var roll_time := 0.0
var invulnerable := 0.0
var attack_time := 0.0
var combo_window := 0.0
var combo := 0
var buffered := 0.0
var anim := 0.0
var hit_flash := 0.0
var trail_time := 0.0
var texture := preload("res://assets/cat.png")
var ghost: Array[Dictionary] = []

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 7
	shape.shape = circle
	add_child(shape)
	add_to_group("player")

func _physics_process(dt: float) -> void:
	if not game.active:
		queue_redraw()
		return
	anim += dt
	invulnerable = maxf(0,invulnerable-dt)
	hit_flash = maxf(0,hit_flash-dt)
	combo_window = maxf(0,combo_window-dt)
	attack_time = maxf(0,attack_time-dt)
	buffered = maxf(0,buffered-dt)
	stamina = minf(100,stamina+dt*29)
	var move := Input.get_vector("move_left","move_right","move_up","move_down")
	if Input.is_action_just_pressed("attack"): buffered = .18
	if Input.is_action_just_pressed("roll") and stamina>=32 and roll_time<=0 and attack_time<.12:
		if move.length()>.1: face = move.normalized()
		roll_time = .24
		invulnerable = .28
		stamina -= 32
		attack_time = 0
		game.audio.sfx("roll")
	if Input.is_action_just_pressed("special") and focus>=100 and roll_time<=0:
		focus = 0
		invulnerable = .45
		game.fx.ring(position,150,Color("9effe4"),.5)
		game.fx.burst(position,Color("baffed"),45,200)
		game.shake = 6
		game.audio.sfx("chime",.7)
		for e in get_tree().get_nodes_in_group("enemies"):
			if position.distance_to(e.position)<150: e.take_damage(damage*3.4,position,200)
	if roll_time>0:
		roll_time -= dt
		velocity = face*310
		trail_time -= dt
		if trail_time<=0:
			trail_time = .035
			ghost.append({"p":position,"t":.17})
	else:
		if move.length()>.1 and attack_time<=0:
			face = move.normalized()
		velocity = move*speed*(.3 if attack_time>0 else 1.0)
		if buffered>0 and attack_time<=0:
			attack()
	move_and_slide()
	position = position.clamp(Vector2(65,80),Vector2(1035,695))
	for g in ghost: g.t -= dt
	ghost = ghost.filter(func(g): return g.t>0)
	queue_redraw()

func attack() -> void:
	buffered = 0
	combo = (combo+1)%3 if combo_window>0 else 0
	combo_window = .65
	attack_time = .33 if combo==2 else .22
	var heavy := combo==2
	game.audio.sfx("swipe",.8 if heavy else 1.1+combo*.15)
	game.fx.slash(position,face,heavy)
	position += face*4
	var connected := false
	for e in get_tree().get_nodes_in_group("enemies"):
		var to: Vector2 = e.position-position
		if to.length()< (61 if e.kind==3 else 47) and (face.dot(to.normalized())>-.08 or to.length()<17):
			e.take_damage(damage*(1.8 if heavy else 1.0),position,150 if heavy else 75)
			connected = true
	if connected:
		focus = minf(100,focus+12)
		game.hit_stop = .055 if heavy else .032
		game.shake = 4 if heavy else 2

func hurt(amount: float, source: Vector2) -> void:
	if invulnerable>0 or hp<=0 or not game.active: return
	hp = maxf(0,hp-amount)
	invulnerable = .8
	hit_flash = .18
	position += (position-source).normalized()*9
	game.shake = 7
	game.red_flash = .25
	game.audio.sfx("hurt")
	game.fx.number(position+Vector2(-7,-28),str(int(amount)),Color("ffabb1"))
	health_changed.emit()
	if hp<=0: game.finish(false)

func _draw() -> void:
	for g in ghost: draw_texture_rect_region(texture,Rect2(g.p-position+Vector2(-16,-25),Vector2(32,32)),Rect2(0,0,32,32),Color(.5,1,.9,g.t*2))
	draw_ellipse_shadow()
	if invulnerable>0 and roll_time<=0 and int(anim*18)%2==0: return
	var frame := int(anim*(14 if velocity.length()>10 else 4))%8
	var rect := Rect2(-16,-25,32,32)
	if face.x<-.1: rect = Rect2(-16,-25,-32,32)
	draw_texture_rect_region(texture,rect,Rect2(frame*32,0,32,32),Color(2,2,2) if hit_flash>0 else Color.WHITE)
	if focus>=100: draw_arc(Vector2(0,-8),19,anim,anim+4.7,20,Color("b0ffdd",.7),1)

func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2.ZERO,0,Vector2(1,.4))
	draw_circle(Vector2(0,4),11,Color(0,0,0,.3))
	draw_set_transform(Vector2.ZERO)
