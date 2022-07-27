const std = @import("std");

pub const Direction = enum {
    UP,
    DOWN,
    LEFT,
    RIGHT,
};

const Head = struct {
    x: i32,
    y: i32,
    direction: Direction,
};

const Tail = struct {
    x: i32,
    y: i32,
};

const starting_x: i32 = 300;
const starting_y: i32 = 200;
pub const BLOCK_WIDTH: i32 = 20;
pub const BLOCK_HEIGHT: i32 = 20;

pub const Game = struct {
    head: Head,
    tail: std.ArrayList(Tail),
    step_length: i32,

    pub fn init(step_length: i32) !Game {
        const allocator = std.heap.page_allocator;

        return Game{
            .head = Head {
                .x = starting_x,
                .y = starting_y,
                .direction = Direction.RIGHT,
            },
            .tail = std.ArrayList(Tail).init(allocator),
            .step_length = step_length,
        };
    }

    pub fn deinit(self: Game) void {
        self.tail.deinit();
    }

    pub fn grow(self: *Game) !void {
        try self.tail.append(Tail { .x = 0, .y = 0});
       // if(self.tail.items.len > 0) {
       //     self.tail.append(Tail { .x = self.tail.items[self.tail.items.len - 1].x + BLOCK_WIDTH, .y = self.tail.items[self.tail.items.len - 1].y + BLOCK_WIDTH});
       // } else {
       //     self.tail.append(Tail { .x = self.head.x + BLOCK_WIDTH, .y = self.head.y + BLOCK_WIDTH});
       // }
    }

    pub fn update(self: *Game) !void {
        for (self.tail.items) |_, index| {
            var block = &self.tail.items[index];
            if (index == 0) {
                block.* = Tail { .x = self.head.x, .y = self.head.y };

                continue;
            }
            block.x = self.tail.items[index - 1].x - BLOCK_WIDTH;
            block.y = self.tail.items[index - 1].y;
        }

        switch (self.head.direction) {
            .DOWN => self.head.y += self.step_length,
            .UP => self.head.y -= self.step_length,
            .RIGHT => self.head.x += self.step_length,
            .LEFT => self.head.x -= self.step_length,
        }
    }

    pub fn move(self: *Game, direction: Direction) void {
        self.head.direction = direction;
    }
};
