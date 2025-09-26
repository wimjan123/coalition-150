# GameDate Resource
# Handles in-game date and time management

class_name GameDate
extends Resource

@export var year: int = 2025
@export var month: int = 1      # 1-12
@export var day: int = 1        # 1-31
@export var hour: int = 9       # 0-23
@export var minute: int = 0     # 0-59

func advance_time(minutes: int) -> void:
	"""Advance the game time by specified minutes"""
	minute += minutes

	# Handle minute overflow
	while minute >= 60:
		minute -= 60
		hour += 1

	# Handle hour overflow
	while hour >= 24:
		hour -= 24
		day += 1

	# Handle day overflow (simplified - assumes 30 days per month)
	var days_in_month := _get_days_in_month(month, year)
	while day > days_in_month:
		day -= days_in_month
		month += 1

		# Handle month overflow
		if month > 12:
			month = 1
			year += 1

		days_in_month = _get_days_in_month(month, year)

func to_display_string() -> String:
	"""Convert to human-readable display string"""
	var month_names := ["", "January", "February", "March", "April", "May", "June",
		"July", "August", "September", "October", "November", "December"]

	var time_str := "%02d:%02d" % [hour, minute]
	var date_str := "%s %d, %d" % [month_names[month], day, year]

	return "%s - %s" % [date_str, time_str]

func compare(other: GameDate) -> int:
	"""Compare two dates. Returns -1 if this is earlier, 1 if later, 0 if same"""
	if year < other.year: return -1
	if year > other.year: return 1

	if month < other.month: return -1
	if month > other.month: return 1

	if day < other.day: return -1
	if day > other.day: return 1

	if hour < other.hour: return -1
	if hour > other.hour: return 1

	if minute < other.minute: return -1
	if minute > other.minute: return 1

	return 0

func _get_days_in_month(month_num: int, year_num: int) -> int:
	"""Get number of days in a given month"""
	var days_per_month := [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

	# Handle leap year for February
	if month_num == 2 and _is_leap_year(year_num):
		return 29

	return days_per_month[month_num]

func _is_leap_year(year_num: int) -> bool:
	"""Check if year is a leap year"""
	return year_num % 4 == 0 and (year_num % 100 != 0 or year_num % 400 == 0)