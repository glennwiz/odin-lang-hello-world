package gnipahellir

import "core:fmt"
import SDL "vendor:sdl2"
import SDL_Image "vendor:sdl2/image"

WINDOW_FLAGS :: SDL.WINDOW_SHOWN
RENDER_FLAGS :: SDL.RENDERER_ACCELERATED | SDL.RENDERER_PRESENTVSYNC
WINDOW_WIDTH, WINDOW_HEIGHT :: 640, 480
TARGET_DT :: 1000 / 60

Game :: struct {
    perf_frequency: f64,
    renderer: ^SDL.Renderer,
}

game := Game{}

main :: proc() {
    assert(SDL.Init(SDL.INIT_VIDEO) == 0, SDL.GetErrorString())
    assert(SDL_Image.Init(SDL_Image.INIT_PNG) != nil, SDL.GetErrorString())
    defer SDL.Quit()

    window := SDL.CreateWindow(
        "Odin Hello World!",
        SDL.WINDOWPOS_CENTERED,
        SDL.WINDOWPOS_CENTERED,
        WINDOW_WIDTH,
        WINDOW_HEIGHT,
        WINDOW_FLAGS
    )
    assert(window != nil, SDL.GetErrorString())
    defer SDL.DestroyWindow(window)

    game.renderer = SDL.CreateRenderer(window, -1, RENDER_FLAGS)
    assert(game.renderer != nil, SDL.GetErrorString())
    defer SDL.DestroyRenderer(game.renderer)

    game.perf_frequency = f64(SDL.GetPerformanceFrequency())
    start : f64
    end : f64
	counter :  u32  = 0

    event : SDL.Event

    game_loop : for {
        start = get_time()

        // Handle events
        if SDL.PollEvent(&event) {
            if event.type == SDL.EventType.QUIT {
                break game_loop
            }
            if event.type == SDL.EventType.KEYDOWN {
                #partial switch event.key.keysym.scancode {
                    case .ESCAPE:
                        break game_loop
                }
            }
        }

        // Drawing gradient from black to green
        for x := 0; x < WINDOW_WIDTH; x += 1 {
            greenIntensity := u8(f32(x) / f32(WINDOW_WIDTH) * 255)
            SDL.SetRenderDrawColor(game.renderer, 0, greenIntensity, 0, 255)
            SDL.RenderDrawLine(game.renderer, cast(i32) x, 0, cast(i32) x, cast(i32) WINDOW_HEIGHT)
        }

        // Present the renderer's content
        SDL.RenderPresent(game.renderer)

        // Frame rate management
        end = get_time()
        for end - start < TARGET_DT {
            end = get_time()
        }

		if counter == 60
		{
			fmt.println("Start : ", start)
			fmt.println("End : ", end)
			fmt.println("FPS : ", 1000 / (end - start))
			counter = 0
		}
		else
		{
			counter += 1
		}

        fmt.println("FPS : ", 1000 / (end - start))
    }
}

get_time :: proc() -> f64 {
    return f64(SDL.GetPerformanceCounter()) * 1000 / game.perf_frequency
}
