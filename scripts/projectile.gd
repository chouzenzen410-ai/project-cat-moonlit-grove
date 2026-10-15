extends Node2D
var game: Node2D
var velocity := Vector2.ZERO
var damage := 10.0
var tint := Color.WHITE
var life := 8.0

func _ready() -> void:
	add_to_group("projectiles")
	z_index = 12

func _physics_process(dt: float) -> void:
	if not game.active: return
	life -= dt
	position += velocity*dt
	if life<=0 or not Rect2(40,50,1020,670).has_point(position):
		queue_free()
		return
	if position.distance_to(game.player.position)<11:
		if game.player.roll_time>0:
			game.player.focus = minf(100,game.player.focus+4)
			game.fx.burst(position,Color("bbffdb"),4,35)
			queue_free()
		elif game.player.invulnerable<=0:
			game.player.hurt(damage,position-velocity.normalized()*10)
			queue_free()
	queue_redraw()

func _draw() -> void:
	draw_line(-velocity.normalized()*9,Vector2.ZERO,Color(tint,.3),3)
	draw_rect(Rect2(-3,-3,6,6),Color(tint,.35))
	draw_rect(Rect2(-2,-2,4,4),tint)
	draw_rect(Rect2(-1,-1,2,2),Color("fff2d6"))
