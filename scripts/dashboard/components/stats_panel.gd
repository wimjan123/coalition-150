# StatsPanel Component
# Displays the four key stats: Approval Rating, Treasury, Seats, Date

class_name StatsPanel
extends Control

signal crisis_detected()
signal debt_warning_triggered()

@onready var approval_label: Label = $PanelContainer/HBoxContainer/ApprovalContainer/ApprovalLabel
@onready var treasury_label: Label = $PanelContainer/HBoxContainer/TreasuryContainer/TreasuryLabel
@onready var seats_label: Label = $PanelContainer/HBoxContainer/SeatsContainer/SeatsLabel
@onready var date_label: Label = $PanelContainer/HBoxContainer/DateContainer/DateLabel
@onready var crisis_indicator: Label = $PanelContainer/IndicatorsContainer/CrisisIndicator
@onready var debt_warning: Label = $PanelContainer/IndicatorsContainer/DebtWarning

var _current_approval: float = 50.0
var _current_treasury: int = 100000
var _current_seats: int = 75
var _current_date: String = "January 1, 2025"

func _ready() -> void:
	"""Initialize stats panel"""
	_connect_to_game_state()
	_update_display()

func update_stats(stats: Dictionary) -> void:
	"""Update all stats from dictionary"""
	if stats.has("approval"):
		set_approval_rating(stats["approval"])

	if stats.has("treasury"):
		set_treasury(stats["treasury"])

	if stats.has("seats"):
		set_seats(stats["seats"])

	if stats.has("date"):
		set_current_date(stats["date"])

func set_approval_rating(rating: float) -> void:
	"""Set approval rating with crisis detection"""
	var old_approval = _current_approval
	_current_approval = clampf(rating, 0.0, 100.0)

	if approval_label:
		approval_label.text = "%.1f%%" % _current_approval

		# Color coding based on approval level
		if _current_approval >= 70.0:
			approval_label.modulate = Color.GREEN
		elif _current_approval >= 40.0:
			approval_label.modulate = Color.YELLOW
		else:
			approval_label.modulate = Color.RED

	# Crisis detection (≤ 15%)
	if _current_approval <= 15.0 and old_approval > 15.0:
		_show_crisis_indicator()
		crisis_detected.emit()
	elif _current_approval > 15.0:
		_hide_crisis_indicator()

func set_treasury(amount: int) -> void:
	"""Set treasury amount with debt warning"""
	var old_treasury = _current_treasury
	_current_treasury = amount

	if treasury_label:
		treasury_label.text = _format_currency(_current_treasury)

		# Color coding based on treasury level
		if _current_treasury >= 50000:
			treasury_label.modulate = Color.GREEN
		elif _current_treasury >= 0:
			treasury_label.modulate = Color.YELLOW
		else:
			treasury_label.modulate = Color.RED

	# Debt warning detection (< 0)
	if _current_treasury < 0 and old_treasury >= 0:
		_show_debt_warning()
		debt_warning_triggered.emit()
	elif _current_treasury >= 0:
		_hide_debt_warning()

func set_seats(seats: int) -> void:
	"""Set parliamentary seats count"""
	_current_seats = clampi(seats, 0, 150)

	if seats_label:
		seats_label.text = "%d / 150" % _current_seats

		# Color coding based on seats (majority = 76+)
		if _current_seats >= 76:
			seats_label.modulate = Color.GREEN
		elif _current_seats >= 50:
			seats_label.modulate = Color.YELLOW
		else:
			seats_label.modulate = Color.RED

func set_current_date(date_string: String) -> void:
	"""Set current game date"""
	_current_date = date_string

	if date_label:
		date_label.text = _current_date

func get_current_stats() -> Dictionary:
	"""Get current stats as dictionary"""
	return {
		"approval": _current_approval,
		"treasury": _current_treasury,
		"seats": _current_seats,
		"date": _current_date
	}

## Private Methods

func _connect_to_game_state() -> void:
	"""Connect to GameState autoload for automatic updates"""
	if GameState:
		GameState.stats_updated.connect(_on_game_state_updated)

func _update_display() -> void:
	"""Update all display elements"""
	set_approval_rating(_current_approval)
	set_treasury(_current_treasury)
	set_seats(_current_seats)
	set_current_date(_current_date)

func _format_currency(amount: int) -> String:
	"""Format currency with proper separators"""
	var abs_amount = abs(amount)
	var formatted = ""

	if abs_amount >= 1000000:
		formatted = "%.1fM" % (float(abs_amount) / 1000000.0)
	elif abs_amount >= 1000:
		formatted = "%.0fK" % (float(abs_amount) / 1000.0)
	else:
		formatted = str(abs_amount)

	if amount >= 0:
		return "€%s" % formatted
	else:
		return "-€%s" % formatted

func _show_crisis_indicator() -> void:
	"""Show crisis mode indicator"""
	if crisis_indicator:
		crisis_indicator.visible = true

func _hide_crisis_indicator() -> void:
	"""Hide crisis mode indicator"""
	if crisis_indicator:
		crisis_indicator.visible = false

func _show_debt_warning() -> void:
	"""Show debt warning indicator"""
	if debt_warning:
		debt_warning.visible = true

func _hide_debt_warning() -> void:
	"""Hide debt warning indicator"""
	if debt_warning:
		debt_warning.visible = false

## Signal Handlers

func _on_game_state_updated(stats: Dictionary) -> void:
	"""Handle GameState stats update"""
	update_stats(stats)