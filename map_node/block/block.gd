class_name Block
extends Node2D

enum {IORN, COPPER, LUMIUM, STONE, COAL}
const colors = {
	IORN: Color("7f7f7f"),
	COPPER: Color("ae5e3e"),
	LUMIUM: Color("0c8599"),
	STONE: Color("846358"),
	COAL: Color("191919")
}
var id
func set_polygon(polygon:PackedVector2Array)-> void:
	%Collision.set_deferred("polygon", polygon)
	%Polygon.set_deferred("polygon", polygon)
	var point = Vector2.ZERO
	for i in polygon:
		point += i
	point/=polygon.size()
	$Label.position = point
	$Label.text = str(polygon.size()) + " Vertex"
	if polygon.size() <= 3:
		queue_free()
func set_pos(vec:Vector2)-> void:
	position = vec
func set_type(id:int)-> void:
	self.id = id
	%Polygon.color = colors[id]


func _get_global_polygon(polygon:PackedVector2Array)-> PackedVector2Array:
	var arr = []
	for i in polygon:
		arr.append(to_global(i))
	return arr
func _get_local_polygon(polygon:PackedVector2Array)-> PackedVector2Array:
	var arr = []
	for i in polygon:
		arr.append(to_local(i))
	return arr

#------------------------
func _merge_nearby_cut_edges(polygon_points: PackedVector2Array, cut_edges: PackedVector2Array, merge_distance: float) -> PackedVector2Array:
	var merged_cut_edges = PackedVector2Array()
	
	# 遍历多边形顶点，进行合并处理
	for i in range(polygon_points.size()):
		var current_point = polygon_points[i]
		
		# 检查当前顶点是否在裁剪边界中
		if cut_edges.has(current_point):
			# 对裁剪边界顶点进行合并
			if merged_cut_edges.size() > 0 and merged_cut_edges[merged_cut_edges.size() - 1].distance_to(current_point) <= merge_distance:
				continue  # 如果当前顶点距离上一个合并的顶点在阈值内，则跳过
		merged_cut_edges.append(current_point)
	
	# 如果需要保持多边形闭合性，可以在这里添加处理逻辑
	# 注意：如果裁剪边界顶点形成闭合轮廓，可以检查并处理首尾顶点的距离
	
	return merged_cut_edges

func _smooth_cut_edges(polygon_points: PackedVector2Array, cut_edges: PackedVector2Array, iterations: int) -> PackedVector2Array:
	var smoothed_points = polygon_points.duplicate()

	for inter in range(iterations):
		var new_points = smoothed_points.duplicate()

		for i in range(smoothed_points.size()):
			var current_point = smoothed_points[i]

			# 仅对裁剪边界顶点进行平滑
			if cut_edges.has(current_point):
				var prev_index = (i - 1 + smoothed_points.size()) % smoothed_points.size()
				var next_index = (i + 1) % smoothed_points.size()
				
				var prev_point = smoothed_points[prev_index]
				var next_point = smoothed_points[next_index]
				
				# 平滑处理
				new_points[i] = (prev_point + next_point) / 2.0
		smoothed_points = new_points
	return smoothed_points

func _reduce_polygon_vertices(polygon_points: PackedVector2Array, angle_threshold: float) -> PackedVector2Array:
	var reduced_points = PackedVector2Array()
	var count = polygon_points.size()
	
	for i in range(count):
		var prev_index = (i - 1 + count) % count
		var next_index = (i + 1) % count
		
		var prev_point = polygon_points[prev_index]
		var current_point = polygon_points[i]
		var next_point = polygon_points[next_index]
		
		var v1 = (prev_point - current_point).normalized()
		var v2 = (next_point - current_point).normalized()
		
		var angle = v1.angle_to(v2)
		
		# 只有当角度大于指定阈值时，才保留当前顶点
		if abs(angle) > deg_to_rad(angle_threshold):
			reduced_points.append(current_point)
	
	return reduced_points

func _get_cut_indices(new:PackedVector2Array, old:PackedVector2Array): # 不包含頭尾的斷面
	var cut_indices = []
	for i in range(new.size()):
		if i == new.size()-1:
			if !old.has(new[i-1]) and !old.has(new[i]) and !old.has(new[0]):
				cut_indices.append(new[i])
				continue
			continue
		if !old.has(new[i-1]) and !old.has(new[i]) and !old.has(new[i+1]):
			cut_indices.append(new[i])
	return cut_indices

var scene = preload("res://map_node/block/block.tscn")


func _fixed_polygon(polygon_points, origin): # 頂點優化
	
	const merge_distance = 10.0
	const iterations = 20
	const angle_threshold = 10.0
	var cut_edges = _get_cut_indices(polygon_points, origin)
	polygon_points = _merge_nearby_cut_edges(polygon_points, cut_edges, merge_distance)
	polygon_points = _smooth_cut_edges(polygon_points, cut_edges, iterations)
	polygon_points = _reduce_polygon_vertices(polygon_points, angle_threshold)
	return polygon_points


func clip(global_polygon:PackedVector2Array):
	var origin = _get_global_polygon(%Collision.polygon)
	var cliped = Geometry2D.clip_polygons(origin, global_polygon)
	if cliped.size() == 0:
		queue_free()
		return
	var poly = cliped.pop_front()
	set_polygon(_get_local_polygon(_fixed_polygon(poly, origin))) # 頂點優化, 轉換至本地
	
	for cpoly:PackedVector2Array in cliped: # 多邊形分裂
		var node = scene.instantiate()
		get_parent().add_child(node)
		node.set_polygon(_get_local_polygon(_fixed_polygon(cpoly, origin))) # 頂點優化, 轉換至本地
		
		node.set_pos(position)
		node.set_type(id)

func merge(global_polygon:PackedVector2Array):
	var origin = _get_global_polygon(%Collision.polygon)
	var merged = Geometry2D.merge_polygons(origin, global_polygon)
	if merged.size() == 0:
		queue_free()
		return
	var poly = merged.pop_front()
	set_polygon(_get_local_polygon(_fixed_polygon(poly, origin))) # 頂點優化, 轉換至本地
	
	for cpoly:PackedVector2Array in merged: # 多邊形分裂
		var node = scene.instantiate()
		get_parent().add_child(node)
		node.set_polygon(_get_local_polygon(_fixed_polygon(cpoly, origin))) # 頂點優化, 轉換至本地
		
		node.set_pos(position)
		node.set_type(id)
	

	
	
	
