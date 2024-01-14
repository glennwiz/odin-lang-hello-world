package main

import "core:fmt"
import SDL "vendor:sdl2"
import SDL_Image "vendor:sdl2/image"

WINDOW_FLAGS :: SDL.WINDOW_SHOWN
RENDER_FLAGS :: SDL.RENDERER_ACCELERATED
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
        "Odin Space Shooter",
        SDL.WINDOWPOS_CENTERED,
        SDL.WINDOWPOS_CENTERED,
        640,
        480,
        WINDOW_FLAGS
    )
    assert(window != nil, SDL.GetErrorString())
    defer SDL.DestroyWindow(window)

    renderer := SDL.CreateRenderer(window, -1, RENDER_FLAGS)
    assert(renderer != nil, SDL.GetErrorString())
    defer SDL.DestroyRenderer(renderer)

    game.perf_frequency = f64(SDL.GetPerformanceFrequency())
    start: f64
    end: f64

    event: SDL.Event
    state: [^]u8

    game_loop: for {
        start = get_time()

        // Event handling
        state = SDL.GetKeyboardState(nil)
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

        // TODO: Update game state and render

        // Timing for frame rate
        end = get_time()
        for end - start < TARGET_DT {
            end = get_time()
        }

        fmt.println("FPS: ", 1000 / (end - start))
        SDL.RenderPresent(game.renderer)
        SDL.SetRenderDrawColor(game.renderer, 0, 0, 0, 100)
        SDL.RenderClear(game.renderer)
    }
}

get_time :: proc() -> f64 {
    return f64(SDL.GetPerformanceCounter()) * 1000 / game.perf_frequency
}

