extends Node2D

@onready var motos = $Motos.get_children()
var vibracion_x: float = 0.0
var vibracion_y: float = 0.0

func _ready():
	%VolverAJugar.visible = false
	%VolverAJugar.pressed.connect(func(): get_tree().reload_current_scene())
	$Motos.get_children().map(func(moto: Node2D):
		moto.set_physics_process(false)
		moto.explote.connect(self.on_moto_exploto)
	)
	await %Timer.timeout
	$Motos.get_children().map(func(moto: Node2D):
		moto.set_physics_process(true)
	)
	%MotosFrenadas.stop_event()
	%MotosAndando.post_event()
	
func on_moto_exploto():
	$ShakeX.start(1.0)
	$ShakeY.start(1.0)
	chequear_si_termino_el_juego()

func chequear_si_termino_el_juego():
	if motos.all(func(moto): return not moto.viva):
		%VolverAJugar.visible = true
		%VolverAJugar.grab_focus()

func _process(delta):
	%Texto.visible = %Timer.time_left > 1.0
	%Texto.text = "%.0f" % %Timer.time_left
	$Camera2D.position.x = vibracion_x
	$Camera2D.position.y = vibracion_y
