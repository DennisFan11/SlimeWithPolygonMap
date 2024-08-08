extends Node2D

enum {IORN, COPPER, LUMIUM, STONE, COAL}
const colors = {
	IORN: Color(0.5, 0.5, 0.5, 1),
	COPPER: Color(0.682353, 0.368627, 0.243137, 1),
	LUMIUM: Color(0.0470588, 0.521569, 0.6, 1),
	STONE: Color(0.517647, 0.388235, 0.345098, 1),
	COAL: Color(0.1, 0.1, 0.1, 1)
}

@onready var nodes:Array[Node2D] = [
	$Iorn,
	$Copper,
	$Lumium,
	$Stone,
	$Coal
]


func set_block(block:Block_data )-> void:
	position = block.pos
	for i:Polygon in block.polygons: # 每種資源
		for poly:PackedVector2Array in i.polygon:
			var body := StaticBody2D.new()
			var polygon = Polygon2D.new()
			var collision = CollisionPolygon2D.new()
			polygon.color = colors[i.type]
			body.add_child(polygon)
			body.add_child(collision)
			
			polygon.polygon = poly
			collision.polygon = poly
			nodes[i.type].add_child(body)



#func get_block()-> Block_data:
	#var data:= Block_data.new()
	#data.pos = position
	#data.polygons
	#return global
