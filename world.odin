package lre

import la "core:math/linalg"
import gl "vendor:OpenGL"

program: u32

// test shapes
cube: Shape
sphere: Shape
torus: Shape
platform: Shape

// 3D gltf models
astronaut: Model
astronautSrc: cstring = "models/astronaut/scene.gltf"
textureId: u32
textureSrc: string = "models/astronaut/textures/m_main_baseColor.png"


model: Mat4
view: Mat4
proj: Mat4
fov := la.to_radians(f32(45.0))

//shader sources/locations
fs_src: string = "shaders/shader.frag"
vs_src: string = "shaders/shader.vert"

init_world :: proc() {


	program, _ = gl.load_shaders_file(vs_src, fs_src)
	use_shader_program(program)
	update_uniform_int(program, "tex", 0)

	platform.mesh = Cube()
	platform.color = {0.2, 0.9, 0.8}
	platform.transform.position = {0.0, -1.0, 0.0}
	platform.transform.scaling = {1e2, 1.0, 1e2}
	cube.transform.rotation = quaternion(w = 1, x = 0, y = 0, z = 0)

	cube.mesh = Cube()
	cube.color = {0.9, 0.5, 0.6}
	cube.transform.position = {0.0, 3.0, 15.0}
	cube.transform.scaling = {1.0, 1.0, 1.0}
	cube.transform.rotation = quaternion(w = 1, x = 0, y = 0, z = 0)

	torus.mesh = Torus(60)
	torus.color = {0.1, 0.9, 0.7}
	torus.transform.position = {-6.0, 3.0, 13.0}
	torus.transform.scaling = {3.0, 3.0, 3.0}
	torus.transform.rotation = quaternion(w = 1, x = 0, y = 0, z = 0)

	sphere.mesh = Sphere(60, 60)
	sphere.color = {0.1, 0.4, 0.7}
	sphere.transform.position = {5.0, 4.0, 15.0}
	sphere.transform.scaling = {2.0, 2.0, 2.0}
	sphere.transform.rotation = quaternion(w = 1, x = 0, y = 0, z = 0)

	astronautData := extract_gltf_data(astronautSrc)
	defer destroy_gltf_data(astronautData)
	astronaut.meshes = extract_gltf_meshes(astronautData)
	astronaut.color = {1.0, 1.0, 1.0}
	astronaut.transform.position = {1.0, 4.0, 7.0}
	astronaut.transform.scaling = {0.2, 0.2, 0.2}
	astronaut.transform.rotation = la.quaternion_angle_axis_f32(
		la.to_radians(f32(180)),
		{0.0, 1.0, 0.0},
	)
	textureId = texture_from_file(textureSrc)

	camera.pos = {0.0, 7.0, -3.0}


}

update_world :: proc() {
	view = camera_view()
	proj = la.matrix4_perspective_f32(fov, win_ratio(), 0.01, 6e2)

	//update once
	use_shader_program(program)
	update_uniform_mat4(program, "view", &view)
	update_uniform_mat4(program, "proj", &proj)
	update_uniform_vec3(program, "lDir", {-0.2, -0.3, 0.9})
}

render_world :: proc() {

	use_shader_program(program)
	//update per object
	model = transform_to_mat(astronaut.transform)
	update_uniform_int(program, "textured", 1)
	gl.ActiveTexture(gl.TEXTURE0)
	bind_texture(textureId)
	update_uniform_mat4(program, "model", &model)
	update_uniform_vec3(program, "inCol", astronaut.color)
	render_model(&astronaut)

	model = transform_to_mat(cube.transform)
	update_uniform_int(program, "textured", 0)
	update_uniform_mat4(program, "model", &model)
	update_uniform_vec3(program, "inCol", cube.color)
	render_shape(&cube)

	model = transform_to_mat(sphere.transform)
	update_uniform_int(program, "textured", 0)
	update_uniform_mat4(program, "model", &model)
	update_uniform_vec3(program, "inCol", sphere.color)
	render_shape(&sphere)

	model = transform_to_mat(torus.transform)
	update_uniform_int(program, "textured", 0)
	update_uniform_mat4(program, "model", &model)
	update_uniform_vec3(program, "inCol", torus.color)
	render_shape(&torus)

	model = transform_to_mat(platform.transform)
	update_uniform_int(program, "textured", 0)
	update_uniform_mat4(program, "model", &model)
	update_uniform_vec3(program, "inCol", platform.color)
	render_shape(&platform)


}

destroy_world :: proc() {

	destroy_shader_programs({program})
	destroy_model(&astronaut)
	destroy_shape(&cube)
	destroy_shape(&platform)
	destroy_shape(&sphere)
	destroy_shape(&torus)
}
