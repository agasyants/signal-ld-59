extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# rotate around Y axis
	rotation.y += delta * 0.2
	rotation.x += delta * 0.1
	rotation.z += delta * 0.05
