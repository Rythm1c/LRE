package lre

import "core:c"
import "core:fmt"
import gl "vendor:OpenGL"
import "vendor:sdl2"


running := true
win: ^sdl2.Window
gl_context: sdl2.GLContext

width, height: u32 = 800, 600


win_ratio :: proc() -> f32 {return f32(width) / f32(height)}

// set up opengl and sdl2
init_window :: proc() {
	// window set up and opengl 
	if (sdl2.Init({.VIDEO}) != 0) {
		fmt.println("failed to init sdl2!")
	}

	flags := sdl2.WINDOW_OPENGL | sdl2.WINDOW_RESIZABLE

	win = sdl2.CreateWindow("odin test", 100, 100, i32(width), i32(height), flags)


	sdl2.GL_SetAttribute(.CONTEXT_PROFILE_MASK, i32(sdl2.GLprofile.CORE))
	sdl2.GL_SetAttribute(.CONTEXT_MAJOR_VERSION, 4)
	sdl2.GL_SetAttribute(.CONTEXT_MINOR_VERSION, 6)

	gl_context = sdl2.GL_CreateContext(win)

	if (sdl2.GL_MakeCurrent(win, gl_context) != 0) {

		fmt.printfln("failed to make opengl context current!")

	}
	sdl2.GL_SetSwapInterval(1)


	gl.load_up_to(4, 6, sdl2.gl_set_proc_address)


	gl.Enable(gl.DEPTH_TEST)
}

// clear window for next render call 
clear_window :: proc() {

	gl.Viewport(0.0, 0.0, i32(width), i32(height))
	gl.ClearColor(0.5, 0.5, 0.5, 1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
}

resize_window :: proc() {
	w: c.int
	h: c.int

	sdl2.GetWindowSize(win, &w, &h)

	width = u32(w)
	height = u32(h)
}

swap_window :: proc() {
	sdl2.GL_SwapWindow(win)
}


clean_window :: proc() {

	sdl2.DestroyWindow(win)
	sdl2.GL_DeleteContext(gl_context)
	sdl2.Quit()
}
