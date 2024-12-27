class_name Kamikaze extends BasicEnemy

@export var acceleration: float = 15


enum kamikaze_state {
	IDLE,
	SEARCHING_FOR_PLAYER,
	KAMIKAZE
}


var state: kamikaze_state = kamikaze_state.IDLE

func _ready() -> void:
	super._ready()


func _physics_process(delta: float) -> void:
	if state == kamikaze_state.SEARCHING_FOR_PLAYER and super.is_player_on_line_of_sight():
		state = kamikaze_state.KAMIKAZE
		turbo = true

	if state == kamikaze_state.KAMIKAZE: speed += acceleration

	super._physics_process(delta)


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	state = kamikaze_state.SEARCHING_FOR_PLAYER
	super._on_visible_on_screen_notifier_2d_screen_entered()
