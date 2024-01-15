package gnipahellir

import "core:fmt"
import SDL "vendor:sdl2"
import SDL_Image "vendor:sdl2/image"

WINDOW_FLAGS :: SDL.WINDOW_SHOWN
RENDER_FLAGS :: SDL.RENDERER_ACCELERATED
TARGET_DT :: 1000 / 60

Game :: struct
{
	perf_frequency: f64,
	renderer: ^SDL.Renderer,
}

game := Game{}

main :: proc()
{
	assert(SDL.Init(SDL.INIT_VIDEO) == 0, SDL.GetErrorString())
	assert(SDL_Image.Init(SDL_Image.INIT_PNG) != nil, SDL.GetErrorString())
	defer SDL.Quit()

	window := SDL.CreateWindow(
		"Odin Hello World!",
		SDL.WINDOWPOS_CENTERED,
		SDL.WINDOWPOS_CENTERED,
		640,
		480,
		WINDOW_FLAGS
	)
	assert(window != nil, SDL.GetErrorString())
	defer SDL.DestroyWindow(window)

	// Must not do VSync because we run the tick loop on the same thread as rendering.
	game.renderer = SDL.CreateRenderer(window, -1, RENDER_FLAGS)
	assert(game.renderer != nil, SDL.GetErrorString())
	defer SDL.DestroyRenderer(game.renderer)

	game.perf_frequency = f64(SDL.GetPerformanceFrequency())
	start : f64
	end : f64	
	counter : u32 = 0

	event : SDL.Event
	state : [^]u8

	game_loop : for
	{
		start = get_time()	
		state = SDL.GetKeyboardState(nil)		

		if SDL.PollEvent(&event)
		{
			if event.type == SDL.EventType.QUIT
			{
				break game_loop
			}

			if event.type == SDL.EventType.KEYDOWN
			{
				#partial switch event.key.keysym.scancode
				{
					case .ESCAPE:
						break game_loop
				}
			}
		}

		// spin lock to hit our framerate
		end = get_time()
		for end - start < TARGET_DT
		{
			end = get_time()
		}

	
		if counter == 60
		{
			fmt.println(state[SDL.SCANCODE_W])
			fmt.println("Start : ", start)
			fmt.println("End : ", end)
			fmt.println("FPS : ", 1000 / (end - start))
			counter = 0
		}
		else
		{
			counter += 1
		}
		
		// actual flipping / presentation of the copy
		// read comments here :: https://wiki.libsdl.org/SDL_RenderCopy
		SDL.RenderPresent(game.renderer)

		// make sure our background is black
		// RenderClear colors the entire screen whatever color is set here
		SDL.SetRenderDrawColor(game.renderer, 0, 0, 0, 255)


		// clear the old scene from the renderer
		// clear after presentation so we remain free to call RenderCopy() throughout our update code / wherever it makes the most sense
		SDL.RenderClear(game.renderer)
	}
}

get_time :: proc() -> f64
{
	return f64(SDL.GetPerformanceCounter()) * 1000 / game.perf_frequency
}
