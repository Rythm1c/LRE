package odin_engine

import "vendor:sdl2"


handleEvents :: proc() {

	event: sdl2.Event

	if (sdl2.PollEvent(&event)) {

		#partial switch event.type {


		case .QUIT:
			running = false


		}
	}


}
