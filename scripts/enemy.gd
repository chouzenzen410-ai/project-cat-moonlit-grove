extends CharacterBody2D
## Shared enemy lifecycle; distinct windup/attack/recovery states, plus boss scheduler.
var game: Node2D
var kind := 0 # 0 spore, 1 moth, 2 bramble boar, 3 eclipse hart
var hp := 40.0
var max_hp := 40.0
var state := "approach"
var timer := 1.0
var time := 0.0
var facing := Vector2.DOWN
var locked := Vector2.ZERO
var knock := Vector2.ZERO
var flash := 0.0
var phase := 1
var pattern := 0
var dead := false
var shot_clock := 0.0
var sprite: Texture2D

func _ready() -> void:
	max_hp = [40.0,30.0,78.0,1100.0][kind]
	hp = max_hp
	sprite = load("res://assets/"+["slime","moth","boar","boss"][kind]+".png")
	collision_layer = 4
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 18 if kind==3 else 8
	shape.shape = circle
	add_child(shape)
	add_to_group("enemies")
	timer = randf_range(.4,1.4)
	if kind==3:
		state = "intro"
		timer = 1.8

func _physics_process(dt: float) -> void:
	if dead or not game.active: return
	time += dt
	timer -= dt
	flash = maxf(0,flash-dt)
	knock = knock.move_toward(Vector2.ZERO,dt*450)
	var delta: Vector2 = game.player.position-position
	var distance := delta.length()
	velocity = Vector2.ZERO
	if kind==3:
		boss_tick(dt,delta)
	else:
		match state:
			"approach":
				facing = delta.normalized()
				var separation := Vector2.ZERO
				for e in get_tree().get_nodes_in_group("enemies"):
					if e!=self and position.distance_squared_to(e.position)<500:
						separation += (position-e.position).normalized()*35
				if kind==1:
					velocity = facing*(40 if distance>150 else -25 if distance<100 else 0)+facing.orthogonal()*sin(time*2)*24
					if timer<=0:
						state = "windup"
						timer = .7
						locked = facing
				else:
					velocity = facing*(44 if kind==0 else 37)+separation
					if distance<(48 if kind==0 else 170) and timer<=0:
						state = "windup"
						timer = .65 if kind==0 else .85
						locked = facing
			"windup":
				if timer<=0:
					if kind==1:
						for a in [-.17,0,.17]: game.projectile(position,locked.rotated(a)*100,9,Color("d3a3e1"))
						state = "recover"
						timer = 1.4
					else:
						state = "charge"
						timer = .26 if kind==0 else .6
			"charge":
				velocity = locked*(210 if kind==0 else 250)
				if distance<23: game.player.hurt(12 if kind==0 else 22,position)
				if timer<=0:
					state = "recover"
					timer = .9
			"recover":
				if timer<=0:
					state = "approach"
					timer = .5
	velocity += knock
	move_and_slide()
	position = position.clamp(Vector2(65,80),Vector2(1035,695))
	queue_redraw()

func boss_tick(dt: float, delta: Vector2) -> void:
	facing = delta.normalized()
	if hp<max_hp*.5 and phase==1 and state!="intro":
		phase = 2
		state = "transition"
		timer = 2.2
		game.clear_projectiles()
		game.banner("THE ECLIPSE AWAKENS",2.2)
		game.fx.ring(position,170,Color("d8a5e5"),1.5)
		game.audio.sfx("chime",.5)
		game.shake = 6
	match state:
		"intro", "transition":
			if timer<=0:
				state = "approach"
				timer = .6
		"approach":
			velocity = facing*29
			if timer<=0:
				pattern = (pattern+1)%3
				state = "windup"
				timer = 1.0 if phase==1 else .75
				locked = game.player.position
		"windup":
			if timer<=0:
				match pattern:
					0:
						state = "barrage"
						timer = 2.4 if phase==2 else 1.8
						shot_clock = 0
					1:
						game.hazard(locked,62,.15)
						if phase==2:
							for i in range(4): game.hazard(locked+Vector2.from_angle(i*TAU/4)*85,42,.65)
						state = "recover"
						timer = 1.4
					2:
						locked = (locked-position).normalized()
						state = "charge"
						timer = .65
		"barrage":
			shot_clock -= dt
			if shot_clock<=0:
				shot_clock = .45 if phase==1 else .32
				var count := 10 if phase==1 else 14
				for i in range(count):
					game.projectile(position,Vector2.from_angle(float(i)*TAU/count+time*.65)*(73 if phase==1 else 90),12,Color("9be7d5") if phase==1 else Color("e2a8dc"))
			if timer<=0:
				state = "recover"
				timer = 1.3
		"charge":
			velocity = locked*265
			if delta.length()<32: game.player.hurt(24,position)
			if timer<=0:
				state = "recover"
				timer = 1.5
		"recover":
			if timer<=0:
				state = "approach"
				timer = .6

func take_damage(amount: float, source: Vector2, force: float) -> void:
	if dead or state in ["intro","transition"]: return
	hp -= amount
	flash = .12
	knock = (position-source).normalized()*force*(.16 if kind==3 else 1.0)
	game.audio.sfx("hit",randf_range(.85,1.2))
	game.fx.burst(position+Vector2(0,-8),Color("d6f7dc"),8)
	game.fx.number(position+Vector2(-5,-35),str(int(amount)),Color("ffefbc"))
	if hp<=0:
		dead = true
		remove_from_group("enemies")
		game.fx.burst(position,Color("a5e6cf"),30,130)
		game.enemy_killed(self)
		queue_free()

func _draw() -> void:
	var boss := kind==3
	var size := 96 if boss else 40 if kind==2 else 32
	var foot := Vector2(0,-4)
	draw_set_transform(foot,0,Vector2(1,.35))
	draw_circle(Vector2.ZERO,25 if boss else 12,Color(0,0,0,.3))
	draw_set_transform(Vector2.ZERO)
	if state=="windup":
		var c := Color("f3ab94",.55)
		if boss and pattern==1:
			draw_circle(locked-position,62,Color(c,.12))
			draw_arc(locked-position,62,0,TAU,48,c,2)
		elif kind!=1 and (not boss or pattern==2):
			var dir: Vector2 = (locked-position).normalized() if boss else locked
			draw_line(Vector2.ZERO,dir*(180 if kind==2 or boss else 52),c,15 if boss else 9)
		else:
			draw_arc(Vector2.ZERO,31 if boss else 20,-time*2,TAU-time*2,40,c,2)
	var frame := int(time*(7 if kind==1 else 5))%4
	var bob := sin(time*5)*3 if kind==1 else 0.0
	var dest := Rect2(-size/2.0,-size+9+bob,size,size)
	if facing.x<-.1: dest = Rect2(-size/2.0,-size+9+bob,-size,size)
	draw_texture_rect_region(sprite,dest,Rect2(frame*size,0,size,size),Color(2,2,2) if flash>0 else Color(1.2,.8,1.1) if phase==2 else Color.WHITE)
	if not boss and hp<max_hp:
		draw_rect(Rect2(-13,-size-1,26,3),Color("25293e"))
		draw_rect(Rect2(-13,-size-1,26*maxf(0,hp/max_hp),2),Color("c3c695"))
