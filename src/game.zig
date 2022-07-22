const std = @import("std");

pub const Direction = enum {
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

const Game = struct {
    head: SnakeBlock,
    tail: std.ArrayList(SnakeBlock),
    step_length: i32,

    pub fn init(snake_x: i32, snake_y: 32, step_length: i32) Game {
        const allocator = std.heap.page_allocator;

        return {
            .head = Game{
                .x = snake_x,
                .y = snake_y,
            };
            tail = std.ArrayList(SnakeBlock).init(allocator);
            .step_length = step_length;
        };
    }

    fn tick() !void {
        std.debug.print("");
    }

    fn move(self: Game, direction: Direction) void {
        switch (direction) {
            .down => {
                self.head.y += stepLength;
            },
            .up => {
                self.head.y -= stepLength;
            },
            .right => {
                self.head.x += stepLength;
            },
            .left => {
                self.head.x -= stepLength;
            },
        }
    }
};
