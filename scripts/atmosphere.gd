extends Control
## Screen-space moon shafts and vignette, no full-screen texture dependencies.
var clock := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(dt: float) -> void:
	clock += dt
	queue_redraw()

func _draw() -> void:
	for i in range(5):
		var x := 90+i*137+sin(clock*.14+i)*13
		draw_colored_polygon(PackedVector2Array([Vector2(x,-20),Vector2(x+24,-20),Vector2(x-160,380),Vector2(x-235,380)]),Color(.65,.83,.95,.018))
	for i in range(18):
		var a := (18-i)*.0014
		draw_rect(Rect2(i*5,i*3,640-i*10,360-i*6),Color(.02,.04,.09,a),false,6)
	# Small moon emblem and drifting foreground leaves.
	for i in range(7):
		var p := Vector2(fposmod(i*137+clock*(8+i),680)-20,fposmod(i*71+clock*5,400)-20)
		draw_line(p,p+Vector2(3,1),Color(.42,.66,.69,.24),2)
