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
		&mesh.vertices[0], // or us raw_data(mesh.vertices) 
		gl.STATIC_DRAW,
	)

	if (len(mesh.indices) != 0) {

		gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, mesh.EBO)
		gl.BufferData(
			gl.ELEMENT_ARRAY_BUFFER,
			size_of(u32) * len(mesh.indices),
			&mesh.indices[0], // or us raw_data(mesh.indices) 
			gl.STATIC_DRAW,
		)
	}
	//_________________________________________________________________________________________________
	// set pointer for position attributes
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, size_of(Vertex), uintptr(0))
	//_________________________________________________________________________________________________
	// set pointer for normal attributes
	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, norm))
	//_________________________________________________________________________________________________
	// set pointer for texture coordinates attributes
	gl.EnableVertexAttribArray(2)
	gl.VertexAttribPointer(2, 2, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, uv))
	//_________________________________________________________________________________________________
	// set pointer for joint weights attributes
	gl.EnableVertexAttribArray(3)
	gl.VertexAttribPointer(3, 4, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, weights))
	//_________________________________________________________________________________________________
	// set pointer for joint id attributes
	gl.EnableVertexAttribArray(4)
	gl.VertexAttribIPointer(4, 4, gl.INT, size_of(Vertex), offset_of(Vertex, ids))

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)
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
