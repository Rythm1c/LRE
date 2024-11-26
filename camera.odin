package odin_engine

import "core:fmt"
import la "core:math/linalg"


Camera :: struct {
	yaw, pitch, velocity: f32,
	pos, front, up:       [3]f32,
}

camera := Camera {
	yaw      = la.to_radians(f32(90.0)),
	pitch    = 0.0,
	velocity = 0.5,
	pos      = [3]f32{0.0, 3.0, 0.0},
	front    = [3]f32{0.0, 0.0, 1.0},
	up       = [3]f32{0.0, 1.0, 0.0},
}

camera_move_left :: proc() {
	result := la.vector_cross3(camera.up, camera.front)
	camera.pos += la.vector_normalize(result) * camera.velocity
}

camera_move_right :: proc() {
	result := la.vector_cross3(camera.up, camera.front)
	camera.pos -= la.vector_normalize(result) * camera.velocity
}

camera_move_forwards :: proc() {
	camera.pos += camera.front * camera.velocity
}

camera_move_backwards :: proc() {
	camera.pos -= camera.front * camera.velocity
}


camera_rotate :: proc(x, y: i32) {
	sensitivity: f32 = 0.2


	camera.yaw += la.to_radians(sensitivity * f32(x))
	camera.pitch += la.to_radians(sensitivity * f32(y))


	camera.pitch = la.clamp(camera.pitch, la.to_radians(f32(-89.0)), la.to_radians(f32(89.0)))


	fx := la.cos(camera.pitch) * la.cos(camera.yaw)
	fy := la.sin(camera.pitch)
	fz := la.cos(camera.pitch) * la.sin(camera.yaw)

}


camera_view :: proc() -> la.Matrix4f32 {

	return la.matrix4_look_at_f32(
		camera.pos, //
		camera.pos + camera.front, //
		camera.up, //
	)
}
