class_name AboutMenu
extends SubMenu
## About menu
##
## The menu that displays information about the game

## Represents the _state of the scroll
enum ScrollState { INITIAL_DELAY, SCROLLING, END_DELAY, RESETTING, STOPPED }

const _SCROLL_SPEED: float = 0.01  ## How fast the scroll bar will scroll
const _DELAY_TIME: float = 2.0  ## Delay between states

var _state: ScrollState = ScrollState.INITIAL_DELAY  ## Current scroll state
var _scroll_timer: float = 0.0  ## Time doing scroll logic
var _scroll_by_code: bool = false  ## Scroll by code

@onready var back_button: Button = $Back  ## Back button ## Menu Back button
@onready var rich_text_label: RichTextLabel = $Panel/RichTextLabel  ## Rich text label
@onready var scroll_bar: VScrollBar = rich_text_label.get_v_scroll_bar()  ## Ric text scroll bar


# Called when the about menu is added to the scene
func _ready() -> void:
	# invoke the parent _ready
	super._ready()
	# connect the visibility_changed signal
	if not rich_text_label.visibility_changed.connect(self._on_visibility_changed) == OK:
		assert(false, "Failed to connect to visibility_changed signal")

	# connect the scrolling signal for user manual scroll
	if not scroll_bar.scrolling.connect(_on_scroll) == OK:
		assert(false, "Failed to connect to scrolling signal")

	# connect the meta clicked signal
	if not rich_text_label.meta_clicked.connect(_on_meta_clicked) == OK:
		assert(false, "Failed to connect to meta_clicked signal")

	# read from a file about text
	_read_about()

	# initial setup
	_on_visibility_changed()


## Called when the visibility changes
func _on_visibility_changed() -> void:
	# if we become visible reset scroll
	if visible:
		scroll_bar.value = 0
		_state = ScrollState.INITIAL_DELAY
		_scroll_timer = 0.0
	# invoke the parent _on_visibility_changed
	super._on_visibility_changed()


## Called on every frame
func _process(delta: float) -> void:
	# invoke the parent _process
	super._process(delta)

	# if we are visible
	if visible:
		if Input.is_action_pressed("ui_up"):
			scroll_bar.value -= scroll_bar.step
			_state = ScrollState.STOPPED
			return
		if Input.is_action_pressed("ui_down"):
			scroll_bar.value += scroll_bar.step
			_state = ScrollState.STOPPED
			return

		# if we are not stopped auto scroll
		if _state != ScrollState.STOPPED:
			# update the scroll timer
			_scroll_timer += delta
			# check the _state
			_scroll_by_code = true
			match _state:
				ScrollState.INITIAL_DELAY:  # wait for delay and go to scrolling
					if _scroll_timer >= _DELAY_TIME:
						_scroll_timer = 0.0
						_state = ScrollState.SCROLLING
				ScrollState.SCROLLING:  # scroll until end and go to end delay
					if _scroll_timer >= _SCROLL_SPEED:
						_scroll_timer = 0.0
						var previous: float = scroll_bar.value
						scroll_bar.value = scroll_bar.value + scroll_bar.step
						if scroll_bar.value == previous:
							_scroll_timer = 0.0
							_state = ScrollState.END_DELAY
				ScrollState.END_DELAY:  # scroll until end and go to resetting
					if _scroll_timer >= _DELAY_TIME:
						_scroll_timer = 0.0
						scroll_bar.value = 0
						_state = ScrollState.RESETTING
				ScrollState.RESETTING:  # wait for delay and go to the initial _state
					if _scroll_timer >= _DELAY_TIME:
						_scroll_timer = 0.0
						_state = ScrollState.SCROLLING
			_scroll_by_code = false


## Called when we scroll
func _on_scroll() -> void:
	## If we are not scrolling by code is user scrolling, stop auto scroll
	if not _scroll_by_code:
		_state = ScrollState.STOPPED


## Called when a meta is clicked
func _on_meta_clicked(meta: String) -> void:
	if meta.begins_with("https://") or meta.begins_with("http://"):
		if not OS.shell_open(meta) == OK:
			assert(false, "Failed to open url: " + meta)
		await super._play_click_sound()
	_state = ScrollState.STOPPED


## Read the about text from a file
func _read_about() -> void:
	# open the file and read the bbcode
	var about_file: FileAccess = FileAccess.open("res://resources/credits/about.bbcode", FileAccess.READ)
	if about_file == null:
		assert(false, "Failed to open about file")
	rich_text_label.parse_bbcode(about_file.get_as_text())
