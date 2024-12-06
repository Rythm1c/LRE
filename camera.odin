package lre

import "core:fmt"
import la "core:math/linalg"

//functions designed to hold only one camera globaly 
//no intention of holding more than one for now 

Camera :: struct {
	yaw, pitch, velocity: f32,
	pos, front, up:       [3]f32,
}

camera := Camera {
	yaw      = la.to_radians(f32(90.0)),
	pitch    = 0.0,
	velocity = 15,
	pos      = [3]f32{0.0, 15.0, 0.0},
	front    = [3]f32{0.0, 0.0, 1.0},
	up       = [3]f32{0.0, 1.0, 0.0},
}

camera_move_left :: proc() {
	result := la.vector_cross3(camera.up, camera.front)
	camera.pos += la.vector_normalize(result) * camera_speed()
}

camera_move_right :: proc() {
	result := la.vector_cross3(camera.up, camera.front)
	camera.pos -= la.vector_normalize(result) * camera_speed()
}

camera_move_forwards :: proc() {
	camera.pos += camera.front * camera_speed()
}

camera_move_backwards :: proc() {
	camera.pos -= camera.front * camera_speed()
}

camera_speed :: proc() -> f32 {
	return camera.velocity * f32(delta)
}

camera_rotate :: proc(x, y: i32) {
	sensitivity: f32 = 0.15


	camera.yaw += la.to_radians(sensitivity * f32(x))
	camera.pitch += la.to_radians(sensitivity * f32(y))


	camera.pitch = la.clamp(camera.pitch, la.to_radians(f32(-89.0)), la.to_radians(f32(89.0)))


	fx := la.cos(camera.pitch) * la.cos(camera.yaw)
	fy := la.sin(camera.pitch)
	fz := la.cos(camera.pitch) * la.sin(camera.yaw)

	camera.front = la.vector_normalize([3]f32{fx, fy, fz})

}


camera_view :: proc() -> Mat4 {

	return la.matrix4_look_at_f32(
		camera.pos, //
		camera.pos + camera.front, //
		camera.up, //
	)
}
