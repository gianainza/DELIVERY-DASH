extends Area2D

@export var is_shop: bool = true # Check this in the Inspector if it's the shop, uncheck for dropoff

func _ready():
	# Automatically connect signals via code so you don't have to do it manually in the Node tab
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		var delivery_manager = get_node_or_null("/root/Game/DeliveryManager")
		if delivery_manager:
			if is_shop:
				delivery_manager.can_pickup = true
				print("Player entered the Shop area!")
			else:
				delivery_manager.can_dropoff = true
				print("Player entered the Drop-off area!")

func _on_body_exited(body):
	if body.name == "Player":
		var delivery_manager = get_node_or_null("/root/Game/DeliveryManager")
		if delivery_manager:
			if is_shop:
				delivery_manager.can_pickup = false
			else:
				delivery_manager.can_dropoff = false
