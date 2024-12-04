package lre

import "core:fmt"
import "core:image"
/* import "core:image/png" */
import "core:image/tga"
import os "core:os/os2"
import "core:strings"
import gl "vendor:OpenGL"

@(private = "file")
pixels :: [dynamic]image.RGB_Pixel

Capture :: struct {
	w, h, fps: u32,
	//raw frame pixels 
	frames:    [dynamic]pixels,
}

@(private = "file")
capture_frame :: proc(w, h: u32) -> (frame: pixels) {

	resize(&frame, w * h)


	gl.PixelStorei(gl.PACK_ALIGNMENT, 1)
	gl.ReadPixels(0, 0, i32(w), i32(h), gl.RGB, gl.UNSIGNED_BYTE, raw_data(frame))

	return

}


// record the screen into the capture frame buffer 
screen_record :: proc(c: ^Capture) {

	append(&c.frames, capture_frame(c.w, c.h))

}

save_screen_recording :: proc(destination: string, c: ^Capture) {


	tmp_dir, _ := os.temp_dir(context.allocator)

	total_frames := len(c.frames)

	for &frame, index in c.frames {

		if img, ok := image.pixels_to_image(frame[:], int(c.w), int(c.h)); ok == true {

			file := [?]string {
				tmp_dir, // temporary directory ("/tmp" in linux)
				fmt.aprintf("/frame_{}.tga", index),
			}

			location := strings.concatenate(file[:])
			tga.save_to_file(location, &img)

			fmt.eprintf("\rprocessing frame {} out of {}", index + 1, total_frames)

		} else {

			fmt.printfln("failed to save captured frame {}", index)

		}
	}

	fmt.eprintfln("\ndone processing frames")

	video_frames := [?]string{tmp_dir, "/frame_%d.tga"}

	ffmpeg_cmd := [?]string {
		"ffmpeg framerate 60 -i ",
		strings.concatenate(video_frames[:]),
		" -c:v libx264 -r 60 -vf vflip -pix_fmt yuv420p ",
		destination,
	}

	/* os.process_exec(
		{command = strings.concatenate(ffmpeg_cmd[:])},
		context.allocator,
	) */


}

// capture a screenshot and save it into a png file with desired name
screen_shot :: proc(destination: string, w, h: u32) {

	frame := capture_frame(w, h)

	if img, ok := image.pixels_to_image(frame[:], int(w), int(h)); ok == true {

		tga.save_to_file(destination, &img)


	} else {

		fmt.printfln("failed to capture a screen shot!")

	}


}
