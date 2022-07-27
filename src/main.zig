const std = @import("std");
const g = @import("game.zig");
const Game = g.Game;
const c = @cImport({
    @cInclude("SDL.h");
});
const Direction = g.Direction;
const BLOCK_HEIGHT = g.BLOCK_HEIGHT;
const BLOCK_WIDTH = g.BLOCK_WIDTH;

const fps: i32 = 60;
const step_length: i32 = 100 / fps;
const time_per_frame: u32 = 1000 / fps;
var sdl_window: *c.SDL_Window = undefined;

pub fn main() anyerror!void {
    _ = c.SDL_Init(c.SDL_INIT_VIDEO);
    defer c.SDL_Quit();

    var window = c.SDL_CreateWindow("hello gamedev", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, 640, 400, 0);
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
    mainloop: while (true) {
        if (start_time == 0) {
            start_time = c.SDL_GetTicks();
        } else {
            delta = end_time -% start_time;
        }
        // std.debug.print("{}\n", .{delta});
        if (delta < time_per_frame) {
            _ = c.SDL_Delay(time_per_frame - delta);
        }

        var sdl_event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&sdl_event) != 0) {
            switch (sdl_event.type) {
                c.SDL_QUIT => break :mainloop,
                c.SDL_KEYDOWN => switch (sdl_event.key.keysym.sym) {
                    c.SDLK_RIGHT => game.move(Direction.RIGHT),
                    c.SDLK_LEFT => game.move(Direction.LEFT),
                    c.SDLK_UP => game.move(Direction.UP),
                    c.SDLK_DOWN => game.move(Direction.DOWN),
                    else => {},
                },
                else => {},
            }
        }

        try game.update();
        _ = c.SDL_SetRenderDrawColor(renderer, 0xff, 0xff, 0xff, 0xff);
        _ = c.SDL_RenderClear(renderer);
        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0xff, 0xff);
        var head_rect = c.SDL_Rect{ .x = game.head.x, .y = game.head.y, .w = BLOCK_WIDTH, .h = BLOCK_HEIGHT };
        _ = c.SDL_RenderFillRect(renderer, &head_rect);
        for (game.tail.items) |block| {
            var rect = c.SDL_Rect{ .x = block.x, .y = block.y, .w = BLOCK_WIDTH, .h = BLOCK_HEIGHT };
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
