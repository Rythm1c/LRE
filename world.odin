package lre

import la "core:math/linalg"
import gl "vendor:OpenGL"

program: u32

// test shapes
cube: Mesh
model: Mat4
view: Mat4
proj: Mat4
fov := la.to_radians(f32(45.0))

init_world :: proc() {

	fs_src: string = "shaders/shader.frag"
	vs_src: string = "shaders/shader.vert"

	program, _ = gl.load_shaders_file(vs_src, fs_src)

	cube = Cube()
	model = la.matrix4_translate_f32({0.0, -1.0, 15.0})

}

update_world :: proc() {
	view = camera_view()
	proj = la.matrix4_perspective_f32(fov, win_ratio(), 0.01, 200.0)

	//update once
	use_shader_program(program)
	update_uniform_mat4(program, "view", &view)
	update_uniform_mat4(program, "proj", &proj)
}

render_world :: proc() {

	use_shader_program(program)
	//update per object
	update_uniform_mat4(program, "model", &model)
	render_mesh(&cube)
}

destroy_world :: proc() {

	destroy_shader_programs({program})
	destroy_mesh(&cube)
}
