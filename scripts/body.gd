@tool
extends Node3D

@onready var _mesh := $Mesh

@onready var _mesh_instance := _mesh.mesh as SphereMesh

@export var radius: float:
	get:
		return _mesh_instance.radius
	set(value):
		_mesh_instance.radius = value
		_mesh_instance.height = value * 2

@export var material: Material:
	get:
		return _mesh_instance.material
	set(value):
		_mesh_instance.material = value
