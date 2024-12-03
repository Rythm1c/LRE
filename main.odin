package lre

import "core:fmt"
import "core:time"
import gl "vendor:OpenGL"
import "vendor:sdl2"

// TODO: window resizing - finished 
// impliment screen capture system
// impliment skeletal animations
// impliment abit of physics to give everything life
// impliment a better material handling system
// impliment a GUI(maybe)
// impliment text rendering(maybe)

main :: proc() {

	init_window()
	defer clean_window()

	get_keys()

	init_world()
	defer destroy_world()

	capture: Capture
	capture.w = width
	capture.h = height
	capture.fps = 60

	fmt.printfln("use w, s, a, and d to move around\nleft click and drag to rotate camera ")
	// main loop 
	for running != false {

		stopWatch: time.Stopwatch
		time.stopwatch_start(&stopWatch)

		handle_events()
		clear_window()
		update_world()
		render_world()


		//screen_shot("test.png", width, height)
		screen_record(&capture)

		swap_window()


		time.stopwatch_stop(&stopWatch)
		duration := time.stopwatch_duration(stopWatch)
		fps := 1e0 / time.duration_seconds(duration)

		//fmt.printfln("\r{}", i64(fps))

	}

	save_screen_recording("test.mp4", &capture)

	fmt.printfln("done")

}
