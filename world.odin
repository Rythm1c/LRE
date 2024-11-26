package odin_engine

import gl "vendor:OpenGL"

init_world :: proc() {

	vert := load_shader("shaders/shader.vert", gl.VERTEX_SHADER)
	frag := load_shader("shaders/shader.frag", gl.FRAGMENT_SHADER)
	shader := create_shader_program({vert, frag})
	defer destroy_shaders({&vert, &frag})

	destroy_shader_programs({&shader})

}

update_world :: proc() {

}

render_world :: proc() {

}

destroy_world :: proc() {

}
