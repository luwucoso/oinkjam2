class_name PlayerController extends Node

@export var floor_layer: TileMapLayer
@export var lines_layer: TileMapLayer
@export var sprite: Sprite2D

@export var move_speed: float = 40.0 

var player_position: Vector2i = Vector2i.ZERO
var target_position: Vector2

var path_history: Array[Vector2i] = []

var undo_redo := UndoRedo.new()


func _ready() -> void:
	target_position = floor_layer.map_to_local(player_position)
	sprite.position = target_position
	
	path_history.push_back(player_position)


func _physics_process(delta: float) -> void:
	if sprite.position.distance_to(target_position) > 1.0:
		sprite.position = sprite.position.lerp(target_position, move_speed * delta)
		return

	var moved := false
	var new_pos := player_position

	if Input.is_action_just_pressed("move_right"):
		new_pos.x += 1
		moved = true
	elif Input.is_action_just_pressed("move_left"):
		new_pos.x -= 1
		moved = true
	elif Input.is_action_just_pressed("move_down"):
		new_pos.y += 1
		moved = true
	elif Input.is_action_just_pressed("move_up"):
		new_pos.y -= 1
		moved = true

	if moved:
		var old_pos := player_position

		undo_redo.create_action("Move Player")

		undo_redo.add_do_method(_apply_move.bind(new_pos))
		undo_redo.add_do_method(_push_path.bind(new_pos))

		undo_redo.add_undo_method(_apply_move.bind(old_pos))
		undo_redo.add_undo_method(_pop_path)

		undo_redo.commit_action()

	if Input.is_action_just_pressed("undo"):
		undo_redo.undo()

	if Input.is_action_just_pressed("redo"):
		undo_redo.redo()

	sprite.position = sprite.position.lerp(target_position, move_speed * delta)


func _apply_move(pos: Vector2i) -> void:
	player_position = pos
	target_position = floor_layer.map_to_local(player_position)
	_update_path_visual()


func _push_path(pos: Vector2i) -> void:
	path_history.push_back(pos)
	_update_path_visual()

func _pop_path() -> void:
	if path_history.size() > 1:
		path_history.pop_back()
	_update_path_visual()

func _update_path_visual() -> void:
	lines_layer.clear()
	lines_layer.set_cells_terrain_path(path_history, 0, 0)
