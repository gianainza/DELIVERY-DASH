extends Area2D

var player_node = null
var can_hop_on = false

func _process(_delta):
	if can_hop_on and Input.is_action_just_pressed("order_accept"):
		var hud = get_parent().get_node_or_null("HUD")
		if hud:
			hud.set_hint("")
		player_node.get_on_bike()
		queue_free()

func _on_body_entered(body):
	if body.has_method("get_on_bike"):
		can_hop_on = true
		player_node = body
		var hud = get_parent().get_node_or_null("HUD")
		if hud:
			hud.set_hint("Press F to hop on the bike")

func _on_body_exited(body):
	if body == player_node:
		can_hop_on = false
		player_node = null
		var hud = get_parent().get_node_or_null("HUD")
		if hud:
			hud.set_hint("")
