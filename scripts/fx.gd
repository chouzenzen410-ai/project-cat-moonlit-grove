extends Node2D
## Deterministic world-space particles, damage labels, telegraphs and slash ribbons.
var bits: Array[Dictionary] = []
var rings: Array[Dictionary] = []
var labels: Array[Dictionary] = []
var slashes: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()

func burst(p: Vector2, color: Color, count := 12, force := 90.0) -> void:
	for i in range(count):
		bits.append({"p":p,"v":Vector2.from_angle(rng.randf()*TAU)*rng.randf_range(force*.3,force),"c":color,"t":rng.randf_range(.18,.5),"life":.5,"size":rng.randi_range(1,3)})

func ring(p: Vector2, radius: float, color: Color, duration := .3) -> void:
	rings.append({"p":p,"r":radius,"c":color,"t":duration,"life":duration})

func number(p: Vector2, value: String, color: Color) -> void:
	labels.append({"p":p,"text":value,"c":color,"t":.75})

func slash(p: Vector2, direction: Vector2, heavy: bool) -> void:
	slashes.append({"p":p,"a":direction.angle(),"t":.18,"heavy":heavy})

func _process(dt: float) -> void:
	for b in bits:
		b.t -= dt
		b.p += b.v*dt
		b.v *= pow(.03,dt)
	for r in rings: r.t -= dt
	for l in labels:
		l.t -= dt
		l.p.y -= dt*24
	for s in slashes: s.t -= dt
	bits = bits.filter(func(b): return b.t>0)
	rings = rings.filter(func(r): return r.t>0)
	labels = labels.filter(func(l): return l.t>0)
	slashes = slashes.filter(func(s): return s.t>0)
	queue_redraw()

func _draw() -> void:
	for b in bits: draw_rect(Rect2(b.p.round(),Vector2.ONE*b.size),Color(b.c,b.t/b.life))
	for r in rings: draw_arc(r.p,r.r*(1-r.t/r.life),0,TAU,48,Color(r.c,r.t/r.life),2)
	for s in slashes:
		var radius: float = 43 if s.heavy else 33
		var progress: float = 1-s.t/.18
		var a: float = s.a-1.3+progress*1.6
		draw_arc(s.p,radius,a,a+1.8,20,Color("faf1cb",s.t/.18),3 if s.heavy else 2)
		draw_arc(s.p,radius-5,a+.2,a+1.6,16,Color("7bedd5",s.t/.18),2)
	for l in labels: draw_string(ThemeDB.fallback_font,l.p,l.text,HORIZONTAL_ALIGNMENT_CENTER,-1,12,Color(l.c,minf(1,l.t*3)))
