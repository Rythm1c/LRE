package odin_engine

import gl "vendor:OpenGL"

shader: Program

init_world :: proc() {

	vert := load_shader("shaders/shader.vert", gl.VERTEX_SHADER)
	frag := load_shader("shaders/shader.frag", gl.FRAGMENT_SHADER)
	shader = create_shader_program({vert, frag})
	defer destroy_shaders({&vert, &frag})


}

update_world :: proc() {

}

render_world :: proc() {

	use_shader_program(&shader)
}

destroy_world :: proc() {

	destroy_shader_programs({&shader})
}
