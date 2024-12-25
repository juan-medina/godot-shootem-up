class_name UI extends Control

# create a property named points with a setter function
@export var points: int = 0:
	set(value):
		points = value
		$Points.text = str(points)