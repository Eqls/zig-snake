const std = @import("std");
const c = @cImport({
    @cInclude("SDL.h");
});

const MovementType = enum {
    horizontal,
    vertical,
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

fn getMovementType(direction: Direction) MovementType {
    return switch (direction) {
        .down, .up => MovementType.vertical,
        .left, .right => MovementType.horizontal,
    };
}

fn updatePos(snake: *std.ArrayList(SnakeBlock)) !void {
    for (snake.items) |_, index| {
        var block = &snake.items[index];
        var current_movement_type = getMovementType(snake.items[index].direction);
        var haveNext = index + 1 >= snake.capacity;
        std.debug.print("{}", .{current_movement_type});
        if (index != 0 and getMovementType(snake.items[index - 1].direction) != current_movement_type
                and (!haveNext or current_movement_type == getMovementType(snake.items[index + 1].direction))) {
            if (current_movement_type == MovementType.horizontal) {
                if (block.x < snake.items[index - 1].x) {
                    block.direction = Direction.right;
                } else if (block.x > snake.items[index - 1].x) {
                    block.direction = Direction.left;
                } else {
                    block.direction = snake.items[index - 1].direction;
                }
            } else {
                if (block.y < snake.items[index - 1].y) {
                    block.direction = Direction.down;
                } else if (block.y > snake.items[index - 1].y) {
                    block.direction = Direction.up;
                } else {
                    block.direction = snake.items[index - 1].direction;
                }
            }
        } else if (index != 0 and (!haveNext or current_movement_type == getMovementType(snake.items[index + 1].direction))) {
            block.direction = snake.items[index - 1].direction;
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
    try snake.append(.{ .x = startingX - blockWidth * 3, .y = startingY, .direction = Direction.right });
    try snake.append(.{ .x = startingX - blockWidth * 4, .y = startingY, .direction = Direction.right });
    try snake.append(.{ .x = startingX - blockWidth * 5, .y = startingY, .direction = Direction.right });
    try snake.append(.{ .x = startingX - blockWidth * 6, .y = startingY, .direction = Direction.right });
    var start_time: u32 = 0;
    var end_time: u32 = 0;
    var delta: u32 = 0;

    mainloop: while (true) {
        if (start_time == 0) {
            start_time = c.SDL_GetTicks();
        } else {
            delta = end_time -% start_time;
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

        try updatePos(&snake);
        _ = c.SDL_SetRenderDrawColor(renderer, 0xff, 0xff, 0xff, 0xff);
        _ = c.SDL_RenderClear(renderer);
        // var rect = drawSnake(&snake);
        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0xff, 0xff);
        for (snake.items) |block| {
            var rect = c.SDL_Rect{ .x = block.x, .y = block.y, .w = blockWidth, .h = blockHeight };
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
