package lre

import "core:fmt"
import gl "vendor:OpenGL"
import "vendor:sdl2"


main :: proc() {

	init_window()
	defer clean_window()

	get_keys()

	init_world()
	defer destroy_world()

	// main loop 
	for {

		if (!running) {
			fmt.printfln("closing window")
			break
		}
		handle_events()
		clear_window()
		update_world()
		render_world()
		swap_window()

	}

	fmt.printfln("done")

}
