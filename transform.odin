package lre

import la "core:math/linalg"

Transform :: struct {
	position, scaling: [3]f32,
	rotation:          quaternion128,
}

transform_to_mat :: proc(t: Transform) -> Mat4 {
	x := la.quaternion128_mul_vector3(t.rotation, [3]f32{1.0, 0.0, 0.0})
	y := la.quaternion128_mul_vector3(t.rotation, [3]f32{0.0, 1.0, 0.0})
	z := la.quaternion128_mul_vector3(t.rotation, [3]f32{0.0, 0.0, 1.0})

	x = x * t.scaling[0]
	y = y * t.scaling[1]
	z = z * t.scaling[2]

	p := t.position

	return {x.x, y.x, z.x, p.x, x.y, y.y, z.y, p.y, x.z, y.z, z.z, p.z, 0.0, 0.0, 0.0, 1.0}


}
