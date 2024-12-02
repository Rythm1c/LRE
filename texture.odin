package lre

import "core:image"
import "core:image/png"
import gl "vendor:OpenGL"


texture_from_file :: proc(path: string) -> (texture: u32) {


	img, err := image.load_from_file(path)
	//image.register(.PNG,)
	defer image.destroy(img)


	gl.CreateTextures(gl.TEXTURE_2D, 1, &texture)
	gl.BindTexture(gl.TEXTURE_2D, texture)


	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)


	gl.TexImage2D(
		gl.TEXTURE_2D,
		0,
		gl.RGB,
		i32(img.width),
		i32(img.height),
		0,
		gl.RGB,
		gl.UNSIGNED_BYTE,
		raw_data(img.pixels.buf),
	)

	gl.GenerateMipmap(gl.TEXTURE_2D)


	return
}

destroy_texture :: proc(texture: ^u32) {

	gl.DeleteTextures(1, texture)
}
