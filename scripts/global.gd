extends Node

# You MUST declare the variable here for other scripts to see it
var lastCameraSpotted: int = -100000000;
var cap_lost = false
var mask_down = false
var mask_hidden = true
# DEFINE SIGNALS HERE

var newspaper_headlines = [
	# Military & Foreign Policy
	"US Army to withdraw from Greenland. 'It's too cold for our liking', says Chief of War.",
	"US Troops expected to invade Jupiter's moons after discovery of natural gas reserves.",
	"Pentagon accidentally declares war on the ocean. 'It was looking at us funny', says General.",
	"Department of War requests $50 Trillion to build a 'Really Big Gun'.",
	"Peace treaties cancelled: 'They were boring to read', admits Secretary of State.",
	"CIA admits to overthrowing a government just to see if they still could.",
	"CIA finds itself innocent in internal investigation",

	# Domestic Politics & Scandals
	"'I am the greatest sex offender in the world, simply the best', claims the President.",
	"Senator caught laundering money through a neighborhood lemonade stand.",
	"White House Press Secretary admits: 'We have no idea what is going on either.'",
	"Secret Plans leaked, to fake a coup to get rid of debt.",
	"FIRE accidentally deports the state of New Mexico after confusion over name.",
	"Third migrating bird shot by porder patrol. Government finds itself innocent.",

	# Absurdist & Bureaucracy
	"Luigi Mango trial postponed by 120 years.",
	"'If anyone can come up with excuses why we are doing what we are, please call our helpline', pleads Press Chief of FIRE.",
	"Statue of Liberty to be replaced by statue of President.",
	"IRS creates new tax bracket for 'People we just don't like'.",
	"Trade War Update: US announces 800% tariff on 'Foreign Ideas', such as 'Freedom of speech' and 'right to ned get shot'.",
	"Diplomats replaced by AI chatbot that only replies with the 'Thumbs Down' emoji."
]

func get_random_headline():
	return newspaper_headlines.pick_random()

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

signal changeNewspaper(new_text: String)

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
