# Example usage from another script (no Autoload):
# var newspaper = $Newspaper
# newspaper.set_title("Breaking News")
# newspaper.set_text("Godot 4.6 is awesome!")
# newspaper.show_newspaper()
# newspaper.hide_newspaper()

extends Node2D

@onready var text: Label = $Newspaper/Text
@onready var title: Label = $Newspaper/Title

func _ready() -> void:
	global.changeNewspaper.connect(_on_changeNewspaper)

# ========================
# NEWSPAPER API
# ========================

func _on_changeNewspaper(new_text: String):
	set_text(new_text)

func set_title(new_title: String) -> void:
	"""Sets the newspaper title"""
	title.text = new_title

func set_text(new_text: String) -> void:
	"""Sets the main newspaper text"""
	text.text = new_text

func show_newspaper() -> void:
	"""Makes the newspaper visible"""
	visible = true

func hide_newspaper() -> void:
	"""Hides the newspaper"""
	visible = false

func set_appearance(new_title: String, new_text: String, show: bool = true) -> void:
	"""Set title, text, and visibility in one call"""
	set_title(new_title)
	set_text(new_text)
	visible = show
