extends Node2D
## Seeded pixel terrain, multi-depth silhouettes, water and emissive-style ambience.
var rng := RandomNumberGenerator.new()
var grass: Array[Dictionary] = []
var flowers: Array[Dictionary] = []
var stones: Array[Vector2] = []
var motes: Array[Vector3] = []
var clock := 0.0
var tree_texture := preload("res://assets/tree.png")
var decor := preload("res://assets/decor.png")

func _ready() -> void:
	rng.seed = 7019
	z_index = -10
	for i in range(3300):
		grass.append({"p":Vector2(rng.randi_range(22,1078),rng.randi_range(35,740)),"c":[Color("1d343b"),Color("203b40"),Color("274449"),Color("2c484c")][rng.randi_range(0,3)],"w":rng.randi_range(1,4)})
	for i in range(130):
		flowers.append({"p":Vector2(rng.randi_range(65,1035),rng.randi_range(85,695)),"id":rng.randi_range(3,7)})
	for p in [Vector2(260,240),Vector2(820,240),Vector2(240,550),Vector2(850,550)]:
		stones.append(p)
		var body := StaticBody2D.new()
		body.position = p
		body.collision_layer = 1
		body.collision_mask = 0
		var shape := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 13
		shape.shape = circle
		body.add_child(shape)
		add_child(body)
	# Decorative trees are y-sorted with actors by the world parent.
	for i in range(44):
		var p: Vector2
		if i<24: p = Vector2(25+(i%12)*95,60 if i<12 else 765)
		else: p = Vector2(20 if i%2==0 else 1080,110+(i/2-12)*65)
		var s := Sprite2D.new()
		s.texture = tree_texture
		s.position = p
		s.offset = Vector2(0,-60)
		s.modulate = Color(.62,.8,.88) if i<12 else Color.WHITE
		get_parent().add_child.call_deferred(s)
	for p in [Vector2(255,270),Vector2(830,255),Vector2(198,430),Vector2(910,445),Vector2(290,650),Vector2(824,675),Vector2(400,175),Vector2(700,160)]:
		var s := Sprite2D.new()
		s.texture = tree_texture
		s.position = p
		s.offset = Vector2(0,-60)
		get_parent().add_child.call_deferred(s)
		var body := StaticBody2D.new()
		body.position = p
		body.collision_layer = 1
		body.collision_mask = 0
		var shape := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 13
		shape.shape = circle
		body.add_child(shape)
		add_child(body)
	for i in range(55): motes.append(Vector3(rng.randf_range(60,1040),rng.randf_range(60,700),rng.randf_range(0,TAU)))

func _process(dt: float) -> void:
	clock += dt
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-600,-500,2300,1800),Color("0b1726"))
	draw_rect(Rect2(26,35,1048,710),Color("192e37"))
	# Meandering slate path and moonwell mosaic.
	for y in range(90,705,12):
		var x := 550+sin(y*.011)*42
		draw_rect(Rect2(x-39,y,78,12),Color("2c4148"))
	for g in grass: draw_rect(Rect2(g.p,Vector2(g.w,1)),g.c)
	# Fern clusters with pixel-stepped fronds, denser around the tree line.
	for i in range(105):
		var x := 87+fposmod(i*193.7,927)
		var y := 110+fposmod(i*107.3,557)
		if absf(x-550)<110: continue
		for j in range(3):
			draw_line(Vector2(x,y),Vector2(x-7+j*6,y-6-abs(j-1)*3),Color("38635b"),1)
			draw_rect(Rect2(x-7,y-7,4,2),Color("457467"))
	for i in range(48):
		var a := i*TAU/48
		var p := Vector2(550,355)+Vector2.from_angle(a)*112
		draw_rect(Rect2(p.round()-Vector2(4,3),Vector2(8,6)),Color("54636a") if i%3 else Color("87958c"))
	draw_circle(Vector2(550,355),64,Color("293f4c"))
	draw_arc(Vector2(550,355),64,0,TAU,64,Color("7c9393"),3)
	draw_circle(Vector2(550,355),57,Color("243e50"))
	for j in range(9):
		var y := 319+j*8
		var width := sqrt(maxf(0,52*52-pow(y-355,2)))*1.7
		draw_line(Vector2(550-width*.5+sin(clock+j)*3,y),Vector2(550+width*.5,y),Color("426577",.7),1)
	draw_arc(Vector2(550,352),25,.3,4.9,32,Color("90c6c4",.5),3)
	for f in flowers: draw_texture_rect_region(decor,Rect2(f.p-Vector2(12,19),Vector2(24,24)),Rect2(f.id*24,0,24,24),Color(1,1,1,.75))
	for p in stones:
		draw_texture_rect_region(decor,Rect2(p-Vector2(18,20),Vector2(36,36)),Rect2(0,0,24,24))
	# Mossy altar above arena.
	draw_rect(Rect2(496,94,108,42),Color("273a48"))
	draw_rect(Rect2(502,91,96,33),Color("586b73"))
	draw_rect(Rect2(509,93,82,24),Color("354c59"))
	for x in [522,550,578]:
		draw_line(Vector2(x,100),Vector2(x-4,111),Color("acdbc7"),2)
		draw_line(Vector2(x-4,111),Vector2(x+3,108),Color("acdbc7"),2)
	# Ruined pillars, hanging moon lanterns and faceted crystal light pools.
	for p in [Vector2(340,205),Vector2(760,205),Vector2(340,570),Vector2(760,570)]:
		draw_circle(p,37,Color("8aead2",.035))
		draw_circle(p,23,Color("8aead2",.04))
		draw_rect(Rect2(p+Vector2(-10,-27),Vector2(20,30)),Color("293d4a"))
		draw_rect(Rect2(p+Vector2(-8,-26),Vector2(16,25)),Color("4a6670"))
		draw_rect(Rect2(p+Vector2(-12,-30),Vector2(24,5)),Color("789091"))
		draw_rect(Rect2(p+Vector2(-13,0),Vector2(26,5)),Color("3c5360"))
		draw_colored_polygon(PackedVector2Array([p+Vector2(0,-47),p+Vector2(-5,-36),p+Vector2(0,-31),p+Vector2(5,-36)]),Color("a5e9cc"))
		draw_line(p+Vector2(0,-44),p+Vector2(0,-34),Color("e7f6c8"),1)
	# Visible boundaries.
	draw_rect(Rect2(54,69,992,638),Color("42666b",.4),false,2)
	for m in motes:
		var p := Vector2(m.x+sin(clock*.7+m.z)*10,m.y+sin(clock*.5+m.z)*7)
		var a := .3+.4*maxf(0,sin(clock*1.3+m.z))
		draw_circle(p,5,Color(.5,1,.8,a*.06))
		draw_rect(Rect2(p.round(),Vector2(2,2)),Color(.7,1,.8,a))
