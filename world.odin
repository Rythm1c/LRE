package lre

import gl "vendor:OpenGL"

program: u32
cube: Mesh


init_world :: proc() {

	fs_src: string = "shaders/shader.frag"
	vs_src: string = "shaders/shader.vert"

	program, _ = gl.load_shaders_file(vs_src, fs_src)

	cube = Cube()


}

update_world :: proc() {

}

render_world :: proc() {

	use_shader_program(program)
}

destroy_world :: proc() {

	destroy_shader_programs({program})
	destroy_mesh(&cube)
}
