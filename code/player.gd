class_name PlayerController extends Node

@export var floor_layer: TileMapLayer
@export var sprite: Sprite2D

var player_position: Vector2i = Vector2i.ZERO
var target_position: Vector2

@export var move_speed: float = 30.0 

func _ready() -> void:
	target_position = floor_layer.map_to_local(player_position)
	sprite.position = target_position

func _physics_process(delta: float) -> void:
	var moved := false

	if Input.is_action_just_pressed("move_right"):
		player_position.x += 1
		moved = true
	elif Input.is_action_just_pressed("move_left"):
		player_position.x -= 1
		moved = true
	elif Input.is_action_just_pressed("move_down"):
		player_position.y += 1
		moved = true
	elif Input.is_action_just_pressed("move_up"):
		player_position.y -= 1
		moved = true

	if moved:
		target_position = floor_layer.map_to_local(player_position)

	sprite.position = sprite.position.lerp(target_position, move_speed * delta)
