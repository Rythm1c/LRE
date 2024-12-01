package lre

import "core:fmt"
import "core:time"
import gl "vendor:OpenGL"
import "vendor:sdl2"


main :: proc() {

	init_window()
	defer clean_window()

	get_keys()

	init_world()
	defer destroy_world()


	// main loop 
	for running != false {

		stopWatch: time.Stopwatch
		time.stopwatch_start(&stopWatch)

		handle_events()
		clear_window()
		update_world()
		render_world()
		swap_window()

		time.stopwatch_stop(&stopWatch)
		duration := time.stopwatch_duration(stopWatch)
		fps := 1e0 / time.duration_seconds(duration)

		//fmt.printfln("\r{}", i64(fps))

	}

	fmt.printfln("done")

}
