package odin_engine

import "core:c"
import "core:fmt"
import "core:os"
import "core:strings"
import gl "vendor:OpenGL"


Shader :: struct {
	id: u32,
}

Program :: struct {
	id: u32,
}

load_shader :: proc(path: string, kind: u32) -> Shader {
	result: Shader

	data, ok := os.read_entire_file(path, context.allocator)
	if (!ok) {
		fmt.printfln("failed to open shader file!")
	}
	defer delete(data, context.allocator)

	shader := string(data)
	length := i32(len(shader))
	shader_copy := cstring(raw_data(shader))

	result.id = gl.CreateShader(kind)

	gl.ShaderSource(result.id, 1, &shader_copy, &length)
	gl.CompileShader(result.id)

	success := 1

	//gl.GetShaderiv(result.id, gl.COMPILE_STATUS, &success)

	return result
}

destroy_shaders :: proc(shaders: []^Shader) {

	for shader in shaders {
		gl.DeleteShader(shader.id)
	}

}

create_shader_program :: proc(shaders: []Shader) -> Program {
	result: Program

	result.id = gl.CreateProgram()

	for shader in shaders {
		gl.AttachShader(result.id, shader.id)
	}

	gl.LinkProgram(result.id)

	return result
}
destroy_shader_programs :: proc(programs: []^Program) {

	for program in programs {
		gl.DeleteProgram(program.id)
	}
}
