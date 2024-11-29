package lre

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

		primitives := _node.mesh.primitives
		for &_primitive in primitives {

			mesh: Mesh

			//first extract the vertex data(attributes)
			for &_attribute in _primitive.attributes {


			}

			// check whether the mesh contains indices or not 
			// if not do nathing 
			count := _primitive.indices.count
			if (count != 0) {

				resize_dynamic_array(&mesh.indices, count)
				for i: u32 = 0; i < u32(count); i += 1 {

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
