extends Node2D

## A data class used to represent a point in 2D space
##
## If [param isLocked] is true, then the point will not be able to move when 
## simulation is running.
class Point:
	var position: Vector2
	var previous_position: Vector2
	var isLocked: bool

	func _init(pos: Vector2, locked: bool):
		self.position = pos
		self.previous_position = pos
		self.isLocked = locked


## A data class used to represent a connection between two points.
##
## The simulation will attempt to keep the length of the stick the same.
class Stick:
	var pointA: Point
	var pointB: Point
	var length: float

	func _init(start: Point, end: Point, distance: float):
		self.pointA = start
		self.pointB = end
		self.length = distance


@export_category("Simulator Settings")
@export var gravity: float = 980.0
@export var number_of_iterations: int = 5

@export_group("Point Settings")
@export var point_radius: float = 10.0
@export var point_margin: float = 5.0

@export_group("Stick Settings")
@export var stick_thickness: float = 10.0
@export var stick_margin: float = 10.0

@export_group("Inital Box")
@export var initalize_box: bool = false
@export var grid_spacing: float = 40.0
@export var grid_width: float = 10.0
@export var grid_height: float = 10.0

var points: Array[Point] = []
var sticks: Array[Stick] = []

var last_pressed: InputEvent
var selected_point: Point = null

var is_paused: bool = true

var pause_texture = load("res://Assets/pause.svg")
var play_texture = load("res://Assets/play.svg")

var point_label: Label
var stick_label: Label

## Toggles the simulation
func pause():
	is_paused = !is_paused
	if is_paused:
		$"UI/PlayPause".texture = pause_texture
	else:
		$"UI/PlayPause".texture = play_texture


func _ready():
	point_label = $"UI/VBoxContainer/PointLabel"
	stick_label = $UI/VBoxContainer/StickLabel

	# Make a box of connected points, useful for cloth simulation
	if initalize_box:
		var viewport_size = get_viewport_rect().size

		var total_width = (grid_width - 1) * grid_spacing
		var total_height = (grid_height - 1) * grid_spacing
		var start_x = (viewport_size.x - total_width) / 2
		var start_y = (viewport_size.y - total_height) / 2

		# Initalizing points
		for row in range(grid_height):
			for col in range(grid_width):
				var pos = Vector2(start_x + col * grid_spacing, start_y + row * grid_spacing)
				points.append(Point.new(pos, false))

		# Initalizing sticks
		for row in range(grid_height):
			for col in range(grid_width):
				var current_index = row * grid_width + col
				var current_point = points[current_index]

				if col < grid_width - 1:
					var right_index = row * grid_width + (col + 1)
					sticks.append(Stick.new(current_point, points[right_index], grid_spacing))

				if row < grid_height - 1:
					var down_index = (row + 1) * grid_width + col
					sticks.append(Stick.new(current_point, points[down_index], grid_spacing))

		queue_redraw()

	point_label.text = "Number of points: %s" % len(points)
	stick_label.text = "Number of Sticks: %s" % len(sticks)


func _input(event):
	# Close when the escape key is opened
	if Input.is_action_just_pressed("Exit"):
		get_tree().quit()

	# Parsing mouse stuff
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Check if we can select a point, if so: set selected point to that point and return
				for point in points:
					# Seeing if mouse position intersects in point diameter + margin
					if point.position.distance_to(event.position) < point_radius * 2 + point_margin:
						print("Point Selected")
						selected_point = point
						return
				# If we cant, make a new point
				points.append(Point.new(event.position, false))
				point_label.text = "Number of points: %s" % len(points)
			else:
				# If we have a selected point, make a new connection
				if selected_point:
					# If a mouse position intersects point diameter + margin, \
					# make a connection between selected point and hovered point
					for point in points:
						if (
							point != selected_point
							and (
								point.position.distance_to(event.position)
								< point_radius * 2 + point_margin
							)
						):
							print("Line Drawn")
							sticks.append(
								Stick.new(
									selected_point,
									point,
									selected_point.position.distance_to(point.position)
								)
							)
							selected_point = null
							stick_label.text = "Number of Sticks: %s" % len(sticks)
							return
					# If there is no point there, 
					# make a new point and make a connection between selected point and new point
					points.append(Point.new(get_local_mouse_position(), false))
					sticks.append(
						Stick.new(
							selected_point,
							points.back(),
							selected_point.position.distance_to(points.back().position)
						)
					)
					selected_point = null
					point_label.text = "Number of points: %s" % len(points)
					stick_label.text = "Number of Sticks: %s" % len(sticks)
		# Toggled locked point, if mouse is over it
		elif event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			for point in points:
				if point.position.distance_to(event.position) < point_radius * 2 + point_margin:
					print("Point Locked")
					point.isLocked = !point.isLocked
					return
	# Cut connections when hovered over while pressing the cut input
	elif Input.is_action_pressed("Cut"):
		for stick in sticks:
			var closest_point = Geometry2D.get_closest_point_to_segment(
				get_local_mouse_position(), stick.pointA.position, stick.pointB.position
			)
			if get_local_mouse_position().distance_to(closest_point) < stick_margin:
				var i = sticks.find(stick)
				sticks.pop_at(i)
				stick_label.text = "Number of Sticks: %s" % len(sticks)

	# Toggling simulation
	if Input.is_action_just_pressed("Pause"):
		pause()
	last_pressed = event


func _process(delta):
	# if there is no points or the sim is paused, no need to run simulation
	if len(points) < 1 or is_paused:
		queue_redraw()
		return

	# Cleaning up points and sticks that are far below the screen
	for i in range(len(points) - 1, -1, -1):
		var p = points[i]
		# The bounds for cleaning up the points is double the height of the viewport
		if p.position.y > get_viewport_rect().size.y * 2:
			for j in range(len(sticks) - 1, -1, -1):
				if sticks[j].pointA == p or sticks[j].pointB == p:
					sticks.pop_at(j)

			points.pop_at(i)
			point_label.text = "Number of points: %s" % len(points)
			stick_label.text = "Number of Sticks: %s" % len(sticks)
			if len(points) < 1:
				pause()
			continue
		
		# Skip locked points
		if p.isLocked:
			continue
		
		# Set previous position
		var previous_position: Vector2 = p.position

		# Affect the point with gravity and inertia
		p.position += p.position - p.previous_position
		p.position += Vector2.DOWN * gravity * delta * delta

		p.previous_position = previous_position
	
	# We need to run the sim multiple times in order to reduce jitter
	for i in range(number_of_iterations):
		for s in sticks:
			var stick_center = (s.pointA.position + s.pointB.position) / 2
			var stick_dir = (s.pointA.position - s.pointB.position).normalized()

			if !s.pointA.isLocked:
				s.pointA.position = stick_center + stick_dir * s.length / 2
			if !s.pointB.isLocked:
				s.pointB.position = stick_center - stick_dir * s.length / 2

	queue_redraw()


func _draw():
	for stick in sticks:
		draw_line(
			stick.pointA.position,
			stick.pointB.position,
			Color.from_string("#777", Color.RED),
			stick_thickness,
			true
		)
	if selected_point:
		draw_dashed_line(
			selected_point.position,
			get_local_mouse_position(),
			Color.DARK_SLATE_GRAY,
			stick_thickness,
			stick_thickness,
			true,
			true
		)

	for point in points:
		var color = Color.PALE_VIOLET_RED if point.isLocked else Color.WHITE
		draw_circle(point.position, point_radius, color, true, -1.0, true)
