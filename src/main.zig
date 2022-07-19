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
const startingX: i32 = 0;
const startingY: i32 = 0;
const startingLength = 1;
const stepLength = blockHeight;
var sdl_window: *c.SDL_Window = undefined;

fn update_pos(snake: *std.ArrayList(SnakeBlock)) !void {
    var modified = false;
    for (snake.items) |block, index| {
        const previousDirection = &snake.items[index - 1].direction;
        if (!modified and previousDirection != &block.direction) {
            block.direction = previousDirection;
            modified = true;
        }

        switch (block.direction) {
            .down => {
                block.y += stepLength;
            },
            .up => {
                block.y -= stepLength;
            },
            .right => {
                block.x += stepLength;
            },
            .left => {
                block.x -= stepLength;
            },
            else => {},
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
    var frame: usize = 0;

    mainloop: while (true) {
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
        c.SDL_RenderPresent(renderer);
        frame += 1;
    }
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
