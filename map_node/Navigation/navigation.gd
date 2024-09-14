extends NavigationRegion2D
static var BlockSize:Vector2i
var GlobalPosition:Vector2i

const agent_radius = 10.0 #pix

func _ready() -> void:
	$Label.position = GlobalPosition

func _bake():
	$Label.text = "baking"
	var chunk_size = Rect2(GlobalPosition,BlockSize)
	
	var baking_bounds: Rect2 = chunk_size.grow(BlockSize.x)

	var chunk_navmesh: NavigationPolygon = NavigationPolygon.new()
	chunk_navmesh.parsed_geometry_type = NavigationPolygon.PARSED_GEOMETRY_STATIC_COLLIDERS
	chunk_navmesh.baking_rect = baking_bounds
	chunk_navmesh.border_size = BlockSize.x
	chunk_navmesh.agent_radius = agent_radius
	
	#FIXME
	navigation_polygon = chunk_navmesh
	NavigationServer2D.bake_from_source_geometry_data(chunk_navmesh, _get_mesh(),_bake_finish)

	# Snap vertex positions to avoid most rasterization issues with float precision.
	# 捕捉頂點位置以避免大多數浮點精度光柵化問題。
	
	var navmesh_vertices: PackedVector2Array = chunk_navmesh.vertices
	for i in navmesh_vertices.size():
		var vertex: Vector2 = navmesh_vertices[i]
		navmesh_vertices[i] = vertex.snappedf(1.0 * 0.1) #0.1 TEST
	chunk_navmesh.vertices = navmesh_vertices
	
	


func _get_mesh()->NavigationMeshSourceGeometryData2D:
	const grow:float = 10.1
	
	var source_geometry: NavigationMeshSourceGeometryData2D = NavigationMeshSourceGeometryData2D.new()
	var parse_settings: NavigationPolygon = NavigationPolygon.new()
	parse_settings.parsed_geometry_type = NavigationPolygon.PARSED_GEOMETRY_STATIC_COLLIDERS
	NavigationServer2D.parse_source_geometry_data(parse_settings, source_geometry, self)
	# FIXME parse_source_geometry_data
	# Add an outline to define the traversable surface that the parsed collision shapes can "cut" into.
	var traversable_outline: PackedVector2Array = PackedVector2Array([
		GlobalPosition + Vector2i(0.0-grow, 0.0-grow),
		GlobalPosition + Vector2i(BlockSize.x+grow, 0.0-grow),
		GlobalPosition + Vector2i(BlockSize.x+grow, BlockSize.x+grow),
		GlobalPosition + Vector2i(0.0-grow, BlockSize.x+grow),
	])
	source_geometry.add_traversable_outline(traversable_outline)
	return source_geometry
	
func _on_timer_timeout() -> void:
	_bake()
	

func ReBake():
	$Timer.start(1.0)
func _bake_finish():
	$Label.text = "baked"
	# The only reason we reset the baking bounds here is to not render its debug.
	# 我們在這裡重置烘焙邊界的唯一原因是不渲染其調試。 TEST
	navigation_polygon.baking_rect = Rect2()
