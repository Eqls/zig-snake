const std = @import("std");

const structs = @import("structs.zig");
const consts = @import("consts.zig");
const Rect = structs.Rect;
const Coordinates = structs.Coordinates;
const Direction = structs.Direction;
const Food = @import("food.zig").Food;

const utils = @import("utils.zig");

const Block = struct {
    x: i32,
    y: i32,
    direction: Direction,
};

const Queue = struct {
    pos: Coordinates,
    direction: Direction,
    index: usize,
};

const starting_x: i32 = 300;
const starting_y: i32 = 200;

pub const Game = struct {
    head: Block,
    tail: std.ArrayList(Block),
    step_length: i32,
    queue: std.ArrayList(Queue),
    food: Food,

    pub fn init(step_length: i32) !Game {
        const allocator = std.heap.page_allocator;

        return Game{
            .head = Block{
                .x = starting_x,
                .y = starting_y,
                .direction = Direction.RIGHT,
            },
            .tail = std.ArrayList(Block).init(allocator),
            .step_length = step_length,
            .queue = std.ArrayList(Queue).init(allocator),
            .food = try Food.init(),
        };
    }

    pub fn deinit(self: Game) void {
        self.tail.deinit();
    }

    pub fn grow(self: *Game) !void {
        var last_block = self.head;

        if (self.tail.items.len > 0) {
            last_block = self.tail.items[self.tail.items.len - 1];
        }

        var new_block = last_block;
        switch (last_block.direction) {
            .UP => new_block.y += consts.BLOCK_WIDTH,
            .DOWN => new_block.y -= consts.BLOCK_WIDTH,
            .LEFT => new_block.x += consts.BLOCK_WIDTH,
            .RIGHT => new_block.x -= consts.BLOCK_WIDTH,
        }

        try self.tail.append(new_block);
    }

    fn didHitAWall(self: Game) bool {
        if (self.head.x >= consts.WINDOW_WIDTH or self.head.x <= 0 or self.head.y >= consts.WINDOW_HEIGHT or self.head.y <= 0) {
            return true;
        }

        return false;
    }

    fn didHitItTail(self: Game) bool {
        for (self.tail.items) |block| {
            if (utils.isColliding(Rect{
                .x = self.head.x,
                .y = self.head.y,
                .w = consts.BLOCK_WIDTH,
                .h = consts.BLOCK_HEIGHT,
            }, Rect{
                .x = block.x,
                .y = block.y,
                .w = consts.BLOCK_WIDTH,
                .h = consts.BLOCK_HEIGHT,
            })) {
                return true;
            }
        }

        return false;
    }

    fn getQueueIndexByBlockIndex(self: *Game, index: usize) usize {
        for (self.queue.items) |item, i| {
            if (item.index == index) {
                return i;
            }
        }

        return undefined;
    }

    fn removeQueueItemByBlockIndex(self: *Game, index: usize) void {
        for (self.queue.items) |item, i| {
            if (item.index == index) {
                _ = self.queue.orderedRemove(i);
            }
        }
    }

    fn handleFood(self: *Game) !void {
        if (utils.isColliding(Rect{
            .x = self.head.x,
            .y = self.head.y,
            .w = consts.BLOCK_WIDTH,
            .h = consts.BLOCK_HEIGHT,
        }, self.food.rect)) {
            try self.food.shuffle();
            try self.grow();
        }
    }

    pub fn update(self: *Game) !void {
        if (self.didHitAWall()) {
            return;
        }

        try self.handleFood();

        self.moveBlock(&self.head);
        for (self.tail.items) |_, index| {
            var block = &self.tail.items[index];
            var queue_index = self.getQueueIndexByBlockIndex(index);

            if (self.queue.items.len > 0 and queue_index < self.queue.items.len) {
                var target = &self.queue.items[queue_index];
                if (target != undefined and target.direction != block.direction) {
                    switch (target.direction) {
                        .UP, .DOWN => {
                            std.debug.print("target y:{} block y: {}\n", .{ target.pos.y, block.y });
                            if (target.pos.x == block.x) {
                                block.direction = target.direction;
                                if (target.index == self.tail.items.len - 1) {
                                    self.removeQueueItemByBlockIndex(index);
                                } else {
                                    target.index += 1;
                                }
                            }
                        },
                        .LEFT, .RIGHT => {
                            std.debug.print("target x:{} block x: {}\n", .{ target.pos.x, block.x });
                            if (target.pos.y == block.y) {
                                block.direction = target.direction;
                                if (target.index == self.tail.items.len - 1) {
                                    self.removeQueueItemByBlockIndex(index);
                                } else {
                                    target.index += 1;
                                }
                            }
                        },
                    }
                }
            }
            self.moveBlock(block);
        }
    }

    fn moveBlock(self: *Game, block: *Block) void {
        switch (block.direction) {
            .DOWN => block.y += self.step_length,
            .UP => block.y -= self.step_length,
            .RIGHT => block.x += self.step_length,
            .LEFT => block.x -= self.step_length,
        }
    }

    pub fn move(self: *Game, direction: Direction) !void {
        if (utils.getAxis(self.head.direction) == utils.getAxis(direction)) {
            return;
        }

        const direction_changed = self.head.direction != direction;
        self.head.direction = direction;
        if (direction_changed or self.queue.items.len == 0) {
            try self.queue.append(Queue{ .direction = direction, .index = 0, .pos = Coordinates{ .x = self.head.x, .y = self.head.y } });
        }
    }
};
