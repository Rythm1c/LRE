package lre

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

	if (len(mesh.indices) != 0) {

		gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, mesh.EBO)
		gl.BufferData(
			gl.ELEMENT_ARRAY_BUFFER,
			size_of(u32) * len(mesh.indices),
			&mesh.indices,
			gl.STATIC_DRAW,
		)
	}

	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, size_of(Vertex), 0)

	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, norm))

	gl.EnableVertexAttribArray(2)
	gl.VertexAttribPointer(2, 2, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, uv))


}

render_mesh :: proc(mesh: ^Mesh) {

	if (len(mesh.indices) == 0) {


		gl.BindVertexArray(mesh.VAO)
		gl.DrawArrays(gl.TRIANGLES, 0, i32(len(mesh.vertices)))
		gl.BindVertexArray(0)


	} else {


		gl.BindVertexArray(mesh.VAO)
		gl.DrawElements(gl.TRIANGLES, i32(len(mesh.indices)), gl.UNSIGNED_INT, nil)
		gl.BindVertexArray(0)


	}
}

destroy_mesh :: proc(mesh: ^Mesh) {

	gl.DeleteVertexArrays(1, &mesh.VAO)
	gl.DeleteBuffers(1, &mesh.VBO)
	gl.DeleteBuffers(1, &mesh.EBO)
}
