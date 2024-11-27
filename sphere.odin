package lre

import la "core:math/linalg"


Sphere :: proc(lats: i32, longs: i32) -> Mesh {
	result: Mesh


	lat_angle: f32 = 180.0 / (f32(lats) - 1.0)
	long_angle: f32 = 360.0 / (f32(longs) - 1.0)
	// tmp vertex
	vert: Vertex


	// get vertices
	for i: i32 = 0; i < lats; i += 1 {
		theta := 90.0 - f32(i) * lat_angle
		vert.pos[1] = la.sin(la.to_radians(theta))
		vert.uv[1] = f32(i) / (f32(lats) - 1.0)

		xy: f32 = la.cos(la.to_radians(theta))

		for j: i32 = 0; j < longs; j += 1 {
			alpha: f32 = long_angle * (f32(j))

			vert.pos[0] = xy * la.cos(la.to_radians(alpha))
			vert.pos[2] = xy * la.sin(la.to_radians(alpha))

			vert.uv[0] = f32(j) / (f32(longs) - 1.0)

			vert.norm = vert.pos

			append(&result.vertices, vert)
		}
	}
	//get indices
	for i: i32 = 0; i < (lats - 1); i += 1 {
		for j: i32 = 0; j < longs; j += 1 {
			append(&result.indices, u32(i * longs + j))
			append(&result.indices, u32(i * longs + (j + 1) % longs))
			append(&result.indices, u32((i + 1) * longs + (j + 1) % longs))

			append(&result.indices, u32((i + 1) * longs + j))
			append(&result.indices, u32(i * longs + j))
			append(&result.indices, u32((i + 1) * longs + (j + 1) % longs))
		}
	}

	init_mesh(&result)

	return result
}
