extends Control
## Pixel-aligned UI; scales with the 640x360 canvas. Keyboard and mouse menus.
var game: Node2D
var font := ThemeDB.fallback_font
var t := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(dt: float) -> void:
	t += dt
	queue_redraw()

func text(p: Vector2, s: String, size := 12, c := Color("dce6d6")) -> void:
	draw_string(font,p,s,HORIZONTAL_ALIGNMENT_LEFT,-1,size,c)

func center(y: float, s: String, size := 14, c := Color("e4e9d5")) -> void:
	text(Vector2(320-font.get_string_size(s,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x/2,y),s,size,c)

func panel(rect: Rect2) -> void:
	draw_rect(rect,Color("101e30",.96))
	draw_rect(rect,Color("648c92"),false,1)
	draw_rect(rect.grow(-3),Color("293e50"),false,1)

func bar(p: Vector2, size: Vector2, ratio: float, c: Color) -> void:
	draw_rect(Rect2(p-Vector2.ONE,size+Vector2(2,2)),Color("182638"))
	draw_rect(Rect2(p,size),Color("344453"))
	draw_rect(Rect2(p,Vector2(size.x*clampf(ratio,0,1),size.y)),c)
	if ratio>0: draw_line(p,p+Vector2(size.x*clampf(ratio,0,1),0),c.lightened(.3),1)

func _draw() -> void:
	var p = game.player
	if game.mode=="title":
		draw_rect(Rect2(0,0,640,360),Color("0c192c",.5))
		text(Vector2(35,35),"AN ORIGINAL PIXEL ACTION VERTICAL SLICE",10,Color("a4c9c8"))
		text(Vector2(34,108),"PROJECT CAT",39,Color("f0e7c9"))
		text(Vector2(36,139),"M O O N L I T   G R O V E",17,Color("8bd9c9"))
		text(Vector2(36,166),"A small guardian. A forest losing its moon.",12)
		text(Vector2(36,185),"Break the eclipse. Bring the light home.",12)
		panel(Rect2(35,211,270,66))
		text(Vector2(49,233),"[ ENTER ]  ENTER THE GROVE",16,Color("eae3bf"))
		text(Vector2(49,257),"3 encounters  /  2-phase boss  /  ~5 minutes",10)
		text(Vector2(36,305),"WASD / ARROWS   Move     J / LMB   Claws",11)
		text(Vector2(36,325),"SPACE   Dodge     K / RMB   Moonburst     M   Audio",11)
		text(Vector2(438,338),"BUILD 0.1  /  GODOT 4",9,Color("6e959e"))
		return
	panel(Rect2(12,12,179,57))
	text(Vector2(21,28),"MISO",12,Color("eee1c5"))
	text(Vector2(136,27),str(int(p.hp))+" / "+str(int(p.max_hp)),9)
	bar(Vector2(21,34),Vector2(160,7),p.hp/p.max_hp,Color("dc8a9d"))
	bar(Vector2(21,46),Vector2(160,4),p.stamina/100,Color("9ecda4"))
	bar(Vector2(21,55),Vector2(160,4),p.focus/100,Color("8fcfe4"))
	text(Vector2(491,24),"MOONLIT GROVE",11,Color("99c5c4"))
	text(Vector2(499,41),"FINAL / BOSS" if game.wave>3 else "WAVE "+str(game.wave)+" / 3",10)
	text(Vector2(499,55),"LIGHT  "+str(game.kills),10)
	text(Vector2(16,346),"J: CLAWS    SPACE: DODGE    K: MOONBURST    ESC: PAUSE",10,Color("9aafb0"))
	if p.focus>=100:
		center(313,"[ K ]  MOONBURST READY",12,Color("b9f4df",.7+sin(t*5)*.3))
	if is_instance_valid(game.boss):
		center(281,"THE ECLIPSE HART  /  "+("AWAKENED" if game.boss.phase==2 else "VEILED"),10,Color("dfc5db"))
		bar(Vector2(180,288),Vector2(280,5),game.boss.hp/game.boss.max_hp,Color("c39abc"))
	if game.banner_time>0:
		center(94,game.banner_text,17,Color("e3e3bf",minf(1,game.banner_time*2)))
	if game.mode in ["upgrade","won","lost","pause"]:
		draw_rect(Rect2(0,0,640,360),Color("071222",.78))
		panel(Rect2(108,83,424,198))
		match game.mode:
			"upgrade":
				center(112,"A GIFT FROM THE GROVE",19,Color("f0e7c9"))
				center(135,"Choose a blessing. Each restores 25 health.",11)
				text(Vector2(140,165),"[1] SHARP CLAWS      +25% claw damage",13)
				text(Vector2(140,194),"[2] NINE LIVES        +25 maximum health",13)
				text(Vector2(140,223),"[3] WINDPAW           +12% movement, +40 focus",13)
				center(259,"Press 1, 2 or 3 to continue",10,Color("9dbab6"))
			"pause":
				center(131,"REST BENEATH THE MOON",21)
				center(164,"ESC  /  Resume     R  /  Restart",13)
				center(190,"M  /  Toggle music and sound",12)
				center(234,"Dodge through danger. The third claw hits hardest.",11)
			"won", "lost":
				center(128,"THE MOON RETURNS" if game.mode=="won" else "A LIGHT STILL LINGERS",23,Color("eae1bd"))
				center(157,"The grove remembers its little guardian." if game.mode=="won" else "Read the warning. Roll through the strike. Try again.",11)
				center(187,"Time  %02d:%02d     Light recovered  %d" % [int(game.elapsed)/60,int(game.elapsed)%60,game.kills],13)
				center(218,"Best  "+game.best_text(),12,Color("9ad1c3"))
				center(255,"[ R / ENTER ]  RETURN TO THE GROVE",13,Color("eae1bd"))
	if game.red_flash>0: draw_rect(Rect2(0,0,640,360),Color(.8,.12,.2,game.red_flash*.45))
