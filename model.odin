package lre

import "core:fmt"
import "vendor:cgltf"

Model :: struct {
	meshes:    [dynamic]Mesh,
	transform: Transform,
	color:     [3]f32,
}

render_model :: proc(model: ^Model) {

	for &mesh in model.meshes {

		render_mesh(&mesh)

	}
}

destroy_model :: proc(model: ^Model) {

	for &mesh in model.meshes {

		destroy_mesh(&mesh)

	}
}

extract_gltf_meshes :: proc(path: cstring) -> [dynamic]Mesh {
	meshes: [dynamic]Mesh

	options: cgltf.options
	data, results := cgltf.parse_file(options, path)

	for &_node in data.nodes {

		if (_node.mesh == nil) {
			continue
		}

		primitives := _node.mesh.primitives
		for &_primitive in primitives {

			mesh: Mesh

			positions: [dynamic][3]f32
			normals: [dynamic][3]f32
			uvs: [dynamic][2]f32


			//first extract the vertex data(attributes)
			for &_attribute in _primitive.attributes {

				attrAccessor := _attribute.data
				compCount: u32 = 0

				#partial switch attrAccessor.type {

				case .vec2:
					compCount = 2


				case .vec3:
					compCount = 3


				case .vec4:
					compCount = 4
				}


				values: [dynamic]f32
				get_scalar_values(&values, compCount, attrAccessor)


				#partial switch _attribute.type 
				{
				//get texture coordinates if any 
				case .texcoord:
					for i: u32 = 0; i < u32(attrAccessor.count); i += 1 {
						index := i * compCount
						append(&uvs, [2]f32{values[index + 0], values[index + 1]})
					}


				//get position coordinates 
				case .position:
					for i: u32 = 0; i < u32(attrAccessor.count); i += 1 {
						index := i * compCount
						append(
							&positions,
							[3]f32{values[index + 0], values[index + 1], values[index + 2]},
						)
					}


				//get normal coordinates 
				case .normal:
					for i: u32 = 0; i < u32(attrAccessor.count); i += 1 {
						index := i * compCount
						append(
							&normals,
							[3]f32{values[index + 0], values[index + 1], values[index + 2]},
						)
					}


				}


			}

			posCount := len(positions)
			

			resize(&mesh.vertices, posCount)

			for i: u32 = 0; i < u32(posCount); i += 1 {

				vert: Vertex
				vert.pos = positions[i]
				vert.norm = normals[i]
				vert.uv = [2]f32{0.0, 0.0}
				if (i < u32(len(uvs))) {
					vert.uv = uvs[i]
				}


			}

			// check whether the mesh contains indices or not 
			// if not do nathing 
			indexCount := _primitive.indices.count
			
			if (indexCount != 0) {

				resize_dynamic_array(&mesh.indices, indexCount)
				for i: u32 = 0; i < u32(indexCount); i += 1 {

					mesh.indices[i] = u32(cgltf.accessor_read_index(_primitive.indices, uint(i)))

				}
			}

			//add mesh to dynamic array
			init_mesh(&mesh)
			append(&meshes, mesh)

		}

	}


	return meshes
}

get_scalar_values :: proc(out: ^[dynamic]f32, compCount: u32, accessor: ^cgltf.accessor) {

	resize(out, u32(accessor.count) * compCount)

	for i: u32 = 0; i < u32(accessor.count); i += 1 {

		_ = cgltf.accessor_read_float(
			accessor, //
			uint(i), //
			&out[i * compCount], //
			uint(compCount),
		)


	}
}