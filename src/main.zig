const std = @import("std");
const c = @cImport({
    @cInclude("SDL.h");
});

const Direction = enum {
    up,
    down,
    left,
    right,
};

const SnakeBlock = struct {
    x: i32,
    y: i32,
    direction: Direction,
};

const blockWidth: i32 = 20;
const blockHeight: i32 = 20;
const startingX: i32 = 300;
const startingY: i32 = 200;
const startingLength = 1;
const fps: i32 = 60;
const stepLength: i32 = 100 / fps;
const timePerFrame: u32 = 1000 / fps;
var sdl_window: *c.SDL_Window = undefined;

fn update_pos(snake: *std.ArrayList(SnakeBlock)) !void {
    var modified = false;
    for (snake.items) |_, index| {
        var block = &snake.items[index];

        if (!modified and index != 0 and snake.items[index - 1].direction != block.direction) {
            block.direction = snake.items[index - 1].direction;
            modified = true;
        }

        switch (block.direction) {
            .down => {
                if (index != 0 and snake.items[index - 1].x != block.x) {
                    if (snake.items[index - 1].x > block.x) {
                        block.x += stepLength;
                    } else {
                        block.x -= stepLength;
                    }
                } else {
                    block.y += stepLength;
                }
            },
            .up => {
                if (index != 0 and snake.items[index - 1].x != block.x) {
                    if (snake.items[index - 1].x > block.x) {
                        block.x += stepLength;
                    } else {
                        block.x -= stepLength;
                    }
                } else {
                    block.y -= stepLength;
                }
            },
            .right => {
                if (index != 0 and snake.items[index - 1].y != block.y) {
                    if (snake.items[index - 1].y > block.y) {
                        block.y += stepLength;
                    } else {
                        block.y -= stepLength;
                    }
                } else {
                    block.x += stepLength;
                }
            },
            .left => {
                if (index != 0 and snake.items[index - 1].y != block.y) {
                    if (snake.items[index - 1].y > block.y) {
                        block.y += stepLength;
                    } else {
                        block.y -= stepLength;
                    }
                } else {
                    block.x -= stepLength;
                }
            },
        }
    }
}

pub fn main() anyerror!void {
    const allocator = std.heap.page_allocator;
    var snake: std.ArrayList(SnakeBlock) = std.ArrayList(SnakeBlock).init(allocator);
    defer snake.deinit();
    _ = c.SDL_Init(c.SDL_INIT_VIDEO);
    defer c.SDL_Quit();

    var window = c.SDL_CreateWindow("hello gamedev", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, 640, 400, 0);
    defer c.SDL_DestroyWindow(window);

    var renderer = c.SDL_CreateRenderer(window, 0, c.SDL_RENDERER_PRESENTVSYNC);
    defer c.SDL_DestroyRenderer(renderer);

    try snake.append(.{ .x = startingX, .y = startingY, .direction = Direction.right });
    try snake.append(.{ .x = startingX - blockWidth, .y = startingY, .direction = Direction.right });
    try snake.append(.{ .x = startingX - blockWidth * 2, .y = startingY, .direction = Direction.right });
    var startTime: u32 = 0;
    var endTime: u32 = 0;
    var delta: u32 = 0;

    mainloop: while (true) {
        if(startTime == 0) {
            startTime = c.SDL_GetTicks();
        } else {
            delta = endTime -% startTime;
        }
        // std.debug.print("{}\n", .{delta});
        std.debug.print("{}\n", .{&snake.items});
        if (delta < timePerFrame) {
            _ = c.SDL_Delay(timePerFrame - delta);
        }

        var sdl_event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&sdl_event) != 0) {
            switch (sdl_event.type) {
                c.SDL_QUIT => break :mainloop,
                c.SDL_KEYDOWN => {
                    var genesisBlock = &snake.items[0];
                    switch (sdl_event.key.keysym.sym) {
                        c.SDLK_RIGHT => {
                            genesisBlock.direction = Direction.right;
                        },
                        c.SDLK_LEFT => {
                            genesisBlock.direction = Direction.left;
                        },
                        c.SDLK_UP => {
                            genesisBlock.direction = Direction.up;
                        },
                        c.SDLK_DOWN => {
                            genesisBlock.direction = Direction.down;
                        },
                        else => {},
                    }
                },
                else => {},
            }
        }

        try update_pos(&snake);
        _ = c.SDL_SetRenderDrawColor(renderer, 0xff, 0xff, 0xff, 0xff);
        _ = c.SDL_RenderClear(renderer);
        // var rect = drawSnake(&snake);
        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0xff, 0xff);
        for (snake.items) |block| {
            var rect = c.SDL_Rect{ .x = block.x, .y = block.y, .w = blockWidth, .h = blockHeight };
            _ = c.SDL_RenderFillRect(renderer, &rect);
        }
        _ = c.SDL_RenderPresent(renderer);
        startTime = endTime;
        endTime = c.SDL_GetTicks();
    }
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
