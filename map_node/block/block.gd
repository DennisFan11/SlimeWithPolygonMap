class_name Block
extends Node2D

enum {COPPER, IORN, COAL, ROCK, LUMIUM, BIOMASS}
const colors = {
	IORN: Color("7f7f7f"),
	COPPER: Color("ae5e3e"),
	LUMIUM: Color("0c8599"),
	ROCK: Color("846358"),
	COAL: Color("191919")
}
var id
func set_polygon(polygon:PackedVector2Array)-> void:
	%Collision.set_deferred("polygon", polygon)
	%Polygon.set_deferred("polygon", polygon)
	$StaticBody2D/LightOccluder2D/Polygon2D.polygon = polygon
	$StaticBody2D/LightOccluder2D.occluder.polygon = polygon
	$StaticBody2D/test_line.points = polygon
	
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
func get_polygon()-> PackedVector2Array: # 建築獲取曲面用
	return _get_global_polygon($StaticBody2D/test_line.points)

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

func calculate_polygon_area(polygon_points: Array[Vector2]) -> float: # 多邊形面積計算
	var area := 0.0
	var n := polygon_points.size()
	
	for i in range(n):
		var j := (i + 1) % n
		area += polygon_points[i].x * polygon_points[j].y
		area -= polygon_points[j].x * polygon_points[i].y

	area = abs(area) / 2.0
	return area


var scene = preload("res://map_node/block/block.tscn")


func _fixed_polygon(polygon_points, origin): # 頂點優化
	
	const merge_distance = 10.0 # 10
	const iterations = 5 #20
	const angle_threshold = 10.0 # 10 30
	var cut_edges = _get_cut_indices(polygon_points, origin)
	polygon_points = _merge_nearby_cut_edges(polygon_points, cut_edges, merge_distance)
	polygon_points = _smooth_cut_edges(polygon_points, cut_edges, iterations)
	polygon_points = _reduce_polygon_vertices(polygon_points, angle_threshold)
	return polygon_points


func find_shortest_connection(outer_polygon: PackedVector2Array, hole_polygon: PackedVector2Array):
	var min_distance = INF
	var best_outer_index = -1
	var best_hole_index = -1

	for i in range(outer_polygon.size()):
		for j in range(hole_polygon.size()):
			var distance = outer_polygon[i].distance_to(hole_polygon[j])
			if distance < min_distance:
				min_distance = distance
				best_outer_index = i
				best_hole_index = j

	return [best_outer_index, best_hole_index]

func connect_hole_with_algorithm(outer_polygon: PackedVector2Array, hole_polygon: PackedVector2Array) -> PackedVector2Array:
	var combined_polygon = PackedVector2Array()
	
	# 确保外多边形闭合
	if outer_polygon[0] != outer_polygon[-1]:
		outer_polygon.append(outer_polygon[0])
	
	# 找到最佳连接点
	var connet = find_shortest_connection(outer_polygon, hole_polygon)
	var outer_index = connet[0]
	var hole_index = connet[1]
	
	# 添加外多边形的顶点，直到连接点
	for i in range(outer_index + 1):
		combined_polygon.append(outer_polygon[i])
	
	# 添加连接缝隙
	var offset = Vector2.ONE*0.1
	combined_polygon.append(hole_polygon[hole_index])
	combined_polygon.append(outer_polygon[outer_index])
	
	# 添加孔的顶点，绕一圈再回到 hole_index
	for j in range(hole_index, hole_polygon.size()):
		combined_polygon.append(hole_polygon[j])
	for j in range(hole_index + 1):
		combined_polygon.append(hole_polygon[j])
		if j == hole_index:
			combined_polygon[-1]+= (combined_polygon[-2]-combined_polygon[-1]).normalized()*offset
		
	# 完成外多边形剩余部分
	for i in range(outer_index, outer_polygon.size()):
		combined_polygon.append(outer_polygon[i])
		if i == outer_index+1:
			combined_polygon[-2]+= (combined_polygon[-1]-combined_polygon[-2]).normalized()*offset
	#combined_polygon.reverse()
	$Timer.start(0.1)
	return combined_polygon


# FIXME remove

func clip(global_polygon:PackedVector2Array)-> float:
	var origin = _get_global_polygon(%Collision.polygon)
	var cliped = Geometry2D.clip_polygons(origin, global_polygon)
	if cliped.size() == 0:
		queue_free()
		return 0.0
	
	var merged:Array[PackedVector2Array] = []
	for i in range(cliped.size()):# 全體優化
		var polygon = _fixed_polygon(cliped[i], origin)
		if Geometry2D.is_polygon_clockwise(polygon) and i!= 0 :
			merged[i-1] = connect_hole_with_algorithm(merged[i-1], polygon)
			continue
		merged.append(polygon)
	
	
	
	var poly = merged.pop_front()
	set_polygon(_get_local_polygon(poly)) # 頂點優化, 轉換至本地
	for cpoly:PackedVector2Array in merged: # 多邊形分裂
		var node = scene.instantiate()
		get_parent().add_child(node)
		node.set_polygon(_get_local_polygon(cpoly)) # 頂點優化, 轉換至本地
		
		node.set_pos(position)
		node.set_type(id)
	
	# 面積計算
	var area:float = 0.0
	var inter_polygons = Geometry2D.intersect_polygons(origin, global_polygon)
	for i in inter_polygons:
		area += calculate_polygon_area(i)
	return area
	


func merge(global_polygon:PackedVector2Array):
	var origin = _get_global_polygon($StaticBody2D/test_line.points)
	var merge_polygon = Geometry2D.merge_polygons(origin, global_polygon)
	if merge_polygon.size() == 0:
		queue_free()
		return
	
	#var merged:Array[PackedVector2Array] = []
	#for i in range(merge_polygon.size()):# 全體優化
		#var polygon = _fixed_polygon(merge_polygon[i], origin)
		#if Geometry2D.is_polygon_clockwise(polygon):
			#merged[i-1] = connect_hole_with_algorithm(merged[i-1], polygon)
			#continue
		#merged.append(polygon)
	var merged = merge_polygon
	
	var poly = merged.pop_front()
	set_polygon(_get_local_polygon(poly)) # 頂點優化, 轉換至本地
	
	for cpoly:PackedVector2Array in merged: # 多邊形分裂
		var node = scene.instantiate()
		get_parent().add_child(node)
		node.set_polygon(_get_local_polygon(cpoly)) # 頂點優化, 轉換至本地
		
		node.set_pos(position)
		node.set_type(id)
	$Timer.start(1)

func no_optimize_merge(global_polygon:PackedVector2Array):
	var origin = _get_global_polygon($StaticBody2D/test_line.points)
	var merge_polygon = Geometry2D.merge_polygons(origin, global_polygon)
	if merge_polygon.size() == 0:
		return
	
	#var merged:Array[PackedVector2Array] = []
	#for i in range(merge_polygon.size()):# 全體優化
		#var polygon = _fixed_polygon(merge_polygon[i], origin)
		#if Geometry2D.is_polygon_clockwise(polygon):
			#merged[i-1] = connect_hole_with_algorithm(merged[i-1], polygon)
			#continue
		#merged.append(polygon)
	var merged = merge_polygon
	
	var poly = merged.pop_front()
	set_polygon(_get_local_polygon(poly)) # 轉換至本地 poly merge_polygon[0]
	
	for cpoly:PackedVector2Array in merged: # 多邊形分裂
		var node = scene.instantiate()
		get_parent().add_child(node)
		node.set_polygon(_get_local_polygon(cpoly)) # 頂點優化, 轉換至本地
		
		node.set_pos(position)
		node.set_type(id)
	
	$Timer.start(1)

func split():
	var BLOCK_SIZE = float(Global.MapNode.BlockSize.x)
	var arr_pos = []
	var arr_poly = []
	var R= 8 # 擴張涉及的區塊 越大的單次擴張需要越大的值
	for x in range(-R,R+1):
		for y in range(-R,R+1):
			if x==0 and y==0:
				continue
			var pos = Vector2(x,y)*BLOCK_SIZE + global_position
			arr_pos.append(pos)
			arr_poly.append(PackedVector2Array([
				Vector2(pos.x,pos.y),
				Vector2(pos.x+BLOCK_SIZE,pos.y),
				Vector2(pos.x+BLOCK_SIZE,pos.y+BLOCK_SIZE),
				Vector2(pos.x,pos.y+BLOCK_SIZE)
			]))
	
	# 相交生成
	for i in range(arr_pos.size()):
		var need_polygon = Geometry2D.intersect_polygons(get_polygon(), arr_poly[i])
		for cpoly:PackedVector2Array in need_polygon: # 多邊形分裂
			var node = scene.instantiate()
			get_parent().add_child(node)
			node.set_pos(arr_pos[i])
			node.set_polygon(node._get_local_polygon(cpoly)) # 頂點優化, 轉換至本地
			
			
			node.set_type(id)
	# 區塊切割
	var polygon = get_polygon()
	for i in range(arr_pos.size()):
		var save = Geometry2D.clip_polygons(polygon, arr_poly[i])
		if save.size() == 0:
			queue_free()
			return
		polygon = save[0]
	set_polygon(_get_local_polygon(polygon)) # 頂點優化, 轉換至本地
	
func after_optimize_clip(global_polygon:PackedVector2Array)-> float:
	var origin = _get_global_polygon(%Collision.polygon)
	if last_origin.size() == 0:
		last_origin = origin
	var cliped = Geometry2D.clip_polygons(origin, global_polygon)
	if cliped.size() == 0:
		queue_free()
		return 0.0
	
	var merged:Array[PackedVector2Array] = []
	for i in range(cliped.size()):# 全體優化
		var polygon = cliped[i]
		if Geometry2D.is_polygon_clockwise(polygon) and i!= 0 :
			merged[i-1] = connect_hole_with_algorithm(merged[i-1], polygon)
			continue
		merged.append(polygon)
	
	var poly = merged.pop_front()
	set_polygon(_get_local_polygon(poly)) # 頂點優化, 轉換至本地
	for cpoly:PackedVector2Array in merged: # 多邊形分裂
		var node = scene.instantiate()
		get_parent().add_child(node)
		node.set_polygon(_get_local_polygon(cpoly)) # 頂點優化, 轉換至本地
		
		node.set_pos(position)
		node.set_type(id)
	# 面積計算
	var area:float = 0.0
	var inter_polygons = Geometry2D.intersect_polygons(origin, global_polygon)
	for i in inter_polygons:
		area += calculate_polygon_area(i)
	$SelfOptimizeTimer.start(1.0)
	return area

var last_origin = []
func self_optimize():
	if last_origin.size() == 0:
		return
	set_polygon(_get_local_polygon(_fixed_polygon(get_polygon(), last_origin)))
	last_origin = PackedVector2Array()
	
	
	
	
func _on_timer_timeout():
	split()


func _on_self_optimize_timer_timeout():
	self_optimize()
