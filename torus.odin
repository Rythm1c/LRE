package lre

import la "core:math"


Torus :: proc(divs: u32) -> Mesh {
	mesh: Mesh

	angle: f32 = 360.0 / (f32(divs) - 1.0)

	vertex: Vertex

	// inner radius = 0.3
	// outer radius = 0.7
	for i: u32 = 0; i < divs; i += 1 {
		epsilon: f32 = la.to_radians(angle * f32(i))

		for j: u32 = 0; j < divs; j += 1 {


			theta := la.to_radians(angle * f32(j))

			hyp: f32 = 0.7 + 0.3 * la.cos(theta)

			x := hyp * la.cos(epsilon)
			y := 0.3 * la.sin(theta)
			z := hyp * la.sin(epsilon)

			nx := la.cos(theta) * la.cos(epsilon)
			ny := la.sin(theta)
			nz := la.cos(theta) * la.sin(epsilon)

			vertex.pos = {x, y, z}
			vertex.norm = {nx, ny, nz}

			append(&mesh.vertices, vertex)
		}
	}

	for i: u32 = 0; i < (divs - 1); i += 1 {
		for j: u32 = 0; j < divs; j += 1 {

			append(&mesh.indices, u32(i * divs + j))
			append(&mesh.indices, u32(i * divs + (j + 1) % divs))
			append(&mesh.indices, u32((i + 1) * divs + (j + 1) % divs))

			append(&mesh.indices, u32((i + 1) * divs + j))
			append(&mesh.indices, u32(i * divs + j))
			append(&mesh.indices, u32((i + 1) * divs + (j + 1) % divs))

		}
	}

	init_mesh(&mesh)

	return mesh
}
