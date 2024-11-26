package odin_engine

import "core:fmt"
import "vendor:sdl2"

keys: i32
keyboard: [^]u8

handle_events :: proc() {

	event: sdl2.Event

	if (sdl2.PollEvent(&event)) {

		#partial switch event.type {


		case .QUIT:
			running = false


		case .KEYDOWN:
		// something


		case .KEYUP:
		//something 


		case .MOUSEMOTION:
			if (event.button.button == sdl2.BUTTON_LEFT) {
				x := event.motion.xrel
				y := -event.motion.yrel
				camera_rotate(x, y)
			}

		}
	}


	if (keyboard[sdl2.SCANCODE_W] == 1) {
		camera_move_forwards()
	}

	if (keyboard[sdl2.SCANCODE_S] == 1) {
		camera_move_backwards()
	}

	if (keyboard[sdl2.SCANCODE_A] == 1) {
		camera_move_left()
	}

	if (keyboard[sdl2.SCANCODE_D] == 1) {
		camera_move_right()
	}

}

get_keys :: proc() {

	keyboard = sdl2.GetKeyboardState(&keys)

}
