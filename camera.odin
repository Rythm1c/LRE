package odin_engine

import "core:fmt"
import la "core:math/linalg"


Camera :: struct {
	yaw, pitch, velocity: f32,
	pos, front, up, dir:  [3]f32,
}

camera := Camera {
	yaw      = la.to_radians(f32(90.0)),
	pitch    = 0.0,
	velocity = 0.5,
	pos      = [3]f32{0.0, 0.0, 0.0},
	front    = [3]f32{0.0, 0.0, 1.0},
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


camera_rotate :: proc() {

}
