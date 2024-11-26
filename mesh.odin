package odin_engine

import gl "vendor:OpenGL"

Mesh :: struct {
	VAO, VBO, EBO: u32,
	vertices:      [dynamic]Vertex,
	indices:       [dynamic]u32,
}

init_mesh :: proc(mesh: ^Mesh) {

	gl.CreateVertexArrays(1, &mesh.VAO)
	gl.CreateBuffers(1, &mesh.VBO)
	if (len(mesh.indices) != 0) {
		gl.CreateBuffers(1, &mesh.EBO)
	}

	gl.BindVertexArray(mesh.VAO)

	gl.BindBuffer(gl.ARRAY_BUFFER, mesh.VBO)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(mesh.vertices) * size_of(Vertex),
		&mesh.vertices,
		gl.STATIC_DRAW,
	)
	// work in progress
	// complete later 
}
