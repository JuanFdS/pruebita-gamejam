@tool
extends CharacterBody2D

const SPEED = 300.0
const TURN_SPEED = 3.0

var direccion: Vector2 = Vector2.UP
const CAMINO = preload("res://player/Camino.tscn")

@export var numero_jugador: int = 0
@export var textura_moto: Texture2D : set = set_textura_moto
@export var color_camino: Color

@onready var camino: Line2D = CAMINO.instantiate()

func set_textura_moto(new_textura: Texture2D):
	textura_moto = new_textura
	$Sprite2D.texture = new_textura

func _ready():
	if Engine.is_editor_hint():
		return
	camino.default_color = color_camino
	get_parent().add_child.call_deferred(camino)
	$Timer.timeout.connect(func():
		self.dejar_camino()
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
	var s = $Sprite2D.duplicate()
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
	var target_direccion := MultiplayerInput.get_vector(numero_jugador, "move_left", "move_right", "move_up", "move_down")
	
	if !target_direccion.is_zero_approx() and abs(target_direccion.angle_to(direccion)) <= PI * 9 / 10:
		direccion = direccion.move_toward(target_direccion, delta * TURN_SPEED)
		velocity = direccion.normalized() * SPEED
		rotation = direccion.angle() + PI/2

	move_and_slide()

func chocaste():
	queue_free()
