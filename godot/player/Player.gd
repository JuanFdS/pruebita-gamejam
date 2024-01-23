@tool
extends CharacterBody2D

enum ConfigIfUsingKeyboard { WASD, Arrows }


const SPEED = 300.0
const TURN_SPEED = 3.0
@export var config_if_using_keyboard: ConfigIfUsingKeyboard = ConfigIfUsingKeyboard.Arrows
@export var nombre: String
@export var direccion: Vector2 = Vector2.UP
const CAMINO = preload("res://player/Camino.tscn")
var viva = true
var exploto = false
var speed = SPEED
var usando_turbo = false
signal explote

@export var numero_jugador: int = 0
@export var textura_moto: SpriteFrames : set = set_textura_moto
@export var color_camino: Color

@onready var camino: Line2D = CAMINO.instantiate()

func _enter_tree():
	if OS.has_feature("web"):
		var wwise_nodes = [$SonidoRIP, $SonidoExplosion]
		wwise_nodes.map(func(node):
			node.free()
		)

func set_textura_moto(new_textura: SpriteFrames):
	textura_moto = new_textura
	$AnimatedSprite2D.sprite_frames = new_textura
	$AnimatedSprite2D.animation = "default"

func _ready():
	$Label.text = nombre
	if Engine.is_editor_hint():
		return
	if(not MultiplayerInput.device_actions.has(numero_jugador)):
		numero_jugador = -1
	velocity = direccion.normalized() * SPEED
	camino.default_color = color_camino
	get_parent().add_child.call_deferred(camino)
	$Timer.timeout.connect(func():
		self.dejar_camino()
		if viva:
			self.dejar_halo()
	)
	
func dejar_camino():
	var indice_nuevo_punto = camino.points.size()
	
	camino.add_point($Escape.global_position)
	
	if indice_nuevo_punto != 0:
		var forma_colision = CollisionShape2D.new()
		camino.get_node("Area2D").add_child(forma_colision)
		var segmento = SegmentShape2D.new()
		segmento.a = camino.points[indice_nuevo_punto - 1]
		segmento.b = camino.points[indice_nuevo_punto]
		forma_colision.shape = segmento

func dejar_halo():
	var s = $AnimatedSprite2D.duplicate()
	s.global_transform = global_transform
	s.z_index = -1
	s.top_level = true
	s.modulate.a = 0.3
	add_child(s)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(s, "modulate:a", 0.0, 1.0)
	tween.tween_property(s, "modulate:r", 0.0, 0.2)
	tween.tween_property(s, "modulate:g", 0.0, 0.2)
	tween.finished.connect(func(): s.queue_free())

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	var target_direccion: Vector2
	if(numero_jugador == -1 and config_if_using_keyboard == ConfigIfUsingKeyboard.WASD):
		target_direccion = Input.get_vector("move_left_wasd", "move_right_wasd", "move_up_wasd", "move_down_wasd")
		usando_turbo = Input.is_action_pressed("turbo_wasd") and viva
	else:
		target_direccion = MultiplayerInput.get_vector(numero_jugador, "move_left", "move_right", "move_up", "move_down")
		usando_turbo = MultiplayerInput.is_action_pressed(numero_jugador, "turbo") and viva
	%Turbo.emitting = usando_turbo
	if viva:
		if !target_direccion.is_zero_approx() and abs(target_direccion.angle_to(direccion)) <= PI * 15 / 16:
			direccion = direccion.move_toward(target_direccion, delta * TURN_SPEED)
			rotation = direccion.angle() + PI/2
		if usando_turbo:
			speed = SPEED * 2.0
			#var max_turbo_speed = SPEED * 2.0
			#speed = move_toward(speed, max_turbo_speed, delta * 5.0)
		else:
			speed = SPEED#move_toward(speed, SPEED, delta * 10.0)
		velocity = direccion.normalized() * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, delta * SPEED)
		$AnimatedSprite2D.rotation += delta * velocity.length() * 0.1
		if(not exploto and velocity.is_zero_approx()):
			explotar()

	

	move_and_slide()

func explotar():
	exploto = true
	explote.emit()
	$AnimatedSprite2D.play("rip")
	#$SonidoExplosion.post_event()

func chocaste():
	viva = false
	$AnimatedSprite2D.animation = "rip"
	#$SonidoRIP.post_event()

