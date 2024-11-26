package odin_engine

import "core:fmt"
import gl "vendor:OpenGL"
import "vendor:sdl2"

width :: 800
height :: 450

main :: proc() {

	init_window()

	defer clean_window()

	// main loop 
	for {

		if (!running) {
			fmt.printfln("closing window")
			break
		}


		handleEvents()

		clear_window()
		// rendering 

		swap_window()


	}

	fmt.printfln("done")

}
