package lre

Model :: struct {
	meshes:    [dynamic]Mesh,
	transform: Transform,
	color:     [3]f32,
}

render_model :: proc(model: ^Model) {

	for &mesh in model.meshes {

		render_mesh(&mesh)

	}
}

destroy_model :: proc(model: ^Model) {

	for &mesh in model.meshes {

		destroy_mesh(&mesh)

	}
}
