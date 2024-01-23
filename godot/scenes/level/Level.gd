extends Node2D

@onready var motos = $Motos.get_children()
var vibracion_x: float = 0.0
var vibracion_y: float = 0.0
var sonando_turbo = false

func _enter_tree():
	if OS.has_feature("web"):
		var wwise_nodes = [
			$AkBank2, $AkBank, $MusicaDeFondo, %MotosFrenadas, %MotosAndando, $AkListener2D, %SonidoTurbo
		]
		wwise_nodes.map(func(node):
			#remove_child(node)
			node.free()
		)

func _ready():
	%VolverAJugar.visible = false
	%VolverAJugar.pressed.connect(func(): get_tree().reload_current_scene())
	motos.map(func(moto: Node2D):
		moto.set_physics_process(false)
		moto.explote.connect(self.on_moto_exploto)
	)
	await %Timer.timeout
	motos.map(func(moto: Node2D):
		moto.set_physics_process(true)
	)
	#%MotosFrenadas.stop_event()
	#%MotosAndando.post_event()
	
func on_moto_exploto():
	$ShakeX.start(1.0)
	$ShakeY.start(1.0)
	chequear_si_termino_el_juego()
	
func hay_un_ganador():
	return motos.filter(func(moto): return moto.viva).size() == 1

func chequear_si_termino_el_juego():
	if motos.all(func(moto): return not moto.viva):
		%VolverAJugar.visible = true
		%VolverAJugar.grab_focus()

func _process(delta):
	var motos_vivas = motos.filter(func(moto): return moto.viva)
	%Texto.visible = %Timer.time_left > 0.0
	if(hay_un_ganador()):
		%Texto.visible = true
		%Texto.text = "Gano %s!" % motos_vivas.front().nombre
	else:
		%Texto.text = "%.0f" % %Timer.time_left if %Timer.time_left > 1.0 else "¡Mandale!"
	$Camera2D.position.x = vibracion_x
	$Camera2D.position.y = vibracion_y
	if(motos.any(func(moto): return moto.usando_turbo)):
		if(not sonando_turbo):
			sonando_turbo = true
			#%SonidoTurbo.post_event()
	else:
		sonando_turbo = false
		#%SonidoTurbo.stop_event()
