const std = @import("std");

const consts = @import("consts.zig");
const WINDOW_WIDTH = consts.WINDOW_WIDTH;
const WINDOW_HEIGHT = consts.WINDOW_HEIGHT;

const structs = @import("structs.zig");
const Direction = structs.Direction;

const g = @import("game.zig");
const Game = g.Game;
const c = @cImport({
    @cInclude("SDL.h");
});

const fps: i32 = 60;
const step_length: i32 = @divTrunc(60, fps);
const time_per_frame: u32 = @divTrunc(1000, fps);
var sdl_window: *c.SDL_Window = undefined;

pub fn main() anyerror!void {
    _ = c.SDL_Init(c.SDL_INIT_VIDEO);
    defer c.SDL_Quit();

    var window = c.SDL_CreateWindow("hello gamedev", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, WINDOW_WIDTH, WINDOW_HEIGHT, 0);
    defer c.SDL_DestroyWindow(window);

    var renderer = c.SDL_CreateRenderer(window, 0, c.SDL_RENDERER_PRESENTVSYNC);
    defer c.SDL_DestroyRenderer(renderer);

    var start_time: u32 = 0;
    var end_time: u32 = 0;
    var delta: u32 = 0;
    var game = try Game.init(step_length);
    defer game.deinit();

    try game.grow();
    try game.grow();
    try game.grow();
    // try game.grow();
    // try game.grow();
    // try game.grow();
    // try game.grow();
    // try game.grow();
    mainloop: while (true) {
        if (start_time == 0) {
            start_time = c.SDL_GetTicks();
        } else {
            delta = end_time -% start_time;
        }

        if (delta < time_per_frame) {
            _ = c.SDL_Delay(time_per_frame - delta);
        }

        var sdl_event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&sdl_event) != 0) {
            switch (sdl_event.type) {
                c.SDL_QUIT => break :mainloop,
                c.SDL_KEYDOWN => switch (sdl_event.key.keysym.sym) {
                    c.SDLK_RIGHT => try game.move(Direction.RIGHT),
                    c.SDLK_LEFT => try game.move(Direction.LEFT),
                    c.SDLK_UP => try game.move(Direction.UP),
                    c.SDLK_DOWN => try game.move(Direction.DOWN),
                    else => {},
                },
                else => {},
            }
        }

        try game.update();

        _ = c.SDL_SetRenderDrawColor(renderer, 0xff, 0xff, 0xff, 0xff);
        _ = c.SDL_RenderClear(renderer);

        // Draws food
        _ = c.SDL_SetRenderDrawColor(renderer, 0x00, 0x64, 0x00, 0xff);
        var food_rect = c.SDL_Rect{
            .x = game.food.rect.x,
            .y = game.food.rect.y,
            .w = game.food.rect.w,
            .h = game.food.rect.h,
        };
        _ = c.SDL_RenderFillRect(renderer, &food_rect);

        // Draws snake it self
        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0xff, 0xff);
        var head_rect = c.SDL_Rect{ .x = game.head.rect.x, .y = game.head.rect.y, .w = game.head.rect.w, .h = game.head.rect.h };
        _ = c.SDL_RenderFillRect(renderer, &head_rect);

        for (game.tail.items) |block| {
            var rect = c.SDL_Rect{ .x = block.rect.x, .y = block.rect.y, .w = block.rect.w, .h = block.rect.h };
            _ = c.SDL_RenderFillRect(renderer, &rect);
        }

        // Using queue items to hide corners
        for (game.queue.items) |block| {
            var rect = c.SDL_Rect{ .x = block.rect.x, .y = block.rect.y, .w = block.rect.w, .h = block.rect.h };
            _ = c.SDL_RenderFillRect(renderer, &rect);
        }

        _ = c.SDL_RenderPresent(renderer);
        start_time = end_time;
        end_time = c.SDL_GetTicks();
    }
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
