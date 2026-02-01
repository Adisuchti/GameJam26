extends Node

# You MUST declare the variable here for other scripts to see it
var lastCameraSpotted: int = -100000000;
var cap_lost = false
var mask_down = false
var mask_hidden = true
# DEFINE SIGNALS HERE

# ========================
# CAP / HAT EVENTS
# ========================
# Emitted when the cap falls off the player
signal cap_fell_off

# Emitted when the player picked up the cap again
signal cap_picked_up

signal cap_hide
signal cap_show

# ========================
# MASK EVENTS
# ========================
# Emitted when mask starts slipping
signal mask_restored

# Emitted when mask is lost forever
signal mask_lost_forever

signal mask_hide
signal mask_show

# ========================
# ITEM EVENTS (GENERIC)
# ========================
# Generic item pickup event
signal item_picked_up(node: Node)


# RUNS EVERY FRAME
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	global.cap_picked_up.connect(_on_cap_picked_up)
	global.cap_fell_off.connect(_on_cap_fell_off)
	global.mask_lost_forever.connect(_on_mask_lost_forever)
	global.mask_restored.connect(_on_mask_restored)
	global.mask_hide.connect(_on_mask_hide)
	global.mask_show.connect(_on_mask_show)


func _on_mask_show() -> void:
	mask_hidden = false
	
func _on_mask_hide() -> void:
	mask_hidden = true

func _on_cap_picked_up() -> void:
	cap_lost = false
	
func _on_cap_fell_off() -> void:
	cap_lost = true

func _on_mask_lost_forever() -> void:
	mask_down = true

func _on_mask_restored() -> void:
	mask_down = false

# ON STARTUP
func _ready() -> void:
	pass


# DEFINE FUNCTIONS HERE
