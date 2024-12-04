package lre


Material :: struct {
	gridCount:  i32,
	enableGrid: i32,
}

Shape :: struct {
	mesh:            Mesh,
	color:           [3]f32,
	using transform: Transform,
	using material:  Material,
}

render_shape :: proc(shape: ^Shape) {

	render_mesh(&shape.mesh)

}

destroy_shape :: proc(shape: ^Shape) {

	destroy_mesh(&shape.mesh)

}
