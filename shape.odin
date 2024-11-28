package lre

Shape :: struct {
	mesh:      Mesh,
	color:     [3]f32,
	transform: Transform,
}

render_shape :: proc(shape: ^Shape) {

	render_mesh(&shape.mesh)

}

destroy_shape :: proc(shape: ^Shape) {

	destroy_mesh(&shape.mesh)

}
