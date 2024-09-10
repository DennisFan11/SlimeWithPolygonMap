extends ItemList

var buildings:Array[PackedScene] = [
	preload("res://map_node/building/drill/drill.tscn"),
	preload("res://map_node/building/furnace/furnace.tscn"),
	preload("res://map_node/building/duo_line_cannon/duo_line_cannon.tscn")
]
func _on_item_clicked(index, at_position, mouse_button_index):
	var node = buildings[index].instantiate()
	Global.MapNode.Building_node.add_child(node)
