class_name Camino
extends Line2D

@onready var area = $Area2D

func _ready():
	area.body_entered.connect(self._on_moto_choco)

func _on_moto_choco(la_moto):
	la_moto.chocaste()
