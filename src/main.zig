const std = @import("std");
const c = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_ttf.h");
});

const consts = @import("consts.zig");
const WINDOW_WIDTH = consts.WINDOW_WIDTH;
const WINDOW_HEIGHT = consts.WINDOW_HEIGHT;

const structs = @import("structs.zig");
const Direction = structs.Direction;

const g = @import("game.zig");
const Game = g.Game;

const Renderer = @import("renderer.zig").Renderer;

const fps: i32 = 60;
const step_length: i32 = @divTrunc(60, fps);
const time_per_frame: u32 = @divTrunc(1000, fps);

pub fn main() anyerror!void {
    var start_time: u32 = 0;
    var end_time: u32 = 0;
    var delta: u32 = 0;

    var game = try Game.init(step_length);
    defer game.deinit();

    var renderer = try Renderer.init();
    defer renderer.deinit();

    try game.grow();
    try game.grow();
    try game.grow();

    mainloop: while (true) {
        if (start_time == 0) {
            start_time = renderer.getTicks();
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

        renderer.clearFrame();

        // Draws food
        renderer.drawRect(game.food.rect, .{ 0x00, 0x64, 0x00, 0xff });

        // Draws snake it self
        renderer.drawRect(game.head.rect, .{ 0, 0, 0xff, 0xff });

        for (game.tail.items) |block| {
            renderer.drawRect(block.rect, .{ 0, 0, 0xff, 0xff });
        }

        // Using queue items to hide corners
        for (game.queue.items) |block| {
            renderer.drawRect(block.rect, .{ 0, 0, 0xff, 0xff });
        }

        var score_array: [8]u8 = undefined;
        const score_slice = score_array[0..];
        const score = try std.fmt.bufPrint(score_slice, "{s} {}", .{ "SCORE:", game.score });
        renderer.drawText(score, .{ .x = 10, .y = 10 }, .{ 0x00, 0x00, 0x00, 0xff });

        renderer.redraw();
        start_time = end_time;
        end_time = renderer.getTicks();
    }
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
