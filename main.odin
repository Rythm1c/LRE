package odin_engine

import "core:fmt"
import gl "vendor:OpenGL"
import "vendor:sdl2"


main :: proc() {

	init_window()
	defer clean_window()
	
	get_keys()

	// main loop 
	for {

		if (!running) {
			fmt.printfln("closing window")
			break
		}
		handle_events()
		clear_window()
		// rendering comes here
		swap_window()

	}

	fmt.printfln("done")

}
