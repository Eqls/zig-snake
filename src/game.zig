const std = @import("std");

const structs = @import("structs.zig");
const consts = @import("consts.zig");
const Rect = structs.Rect;
const Coordinates = structs.Coordinates;
const Direction = structs.Direction;
const Food = @import("food.zig").Food;

const utils = @import("utils.zig");

const Block = struct {
    rect: Rect,
    direction: Direction,
};

const Queue = struct {
    rect: Rect,
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
    gameover: bool,
    length_since_last_turn: i32,

    pub fn init(step_length: i32) !Game {
        const allocator = std.heap.page_allocator;

        return Game{
            .head = Block{
                .rect = Rect{
                    .w = consts.BLOCK_WIDTH,
                    .h = consts.BLOCK_HEIGHT,
                    .x = starting_x,
                    .y = starting_y,
                },
                .direction = Direction.RIGHT,
            },
            .length_since_last_turn = 0,
            .gameover = false,
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
            .UP => new_block.rect.y += consts.BLOCK_WIDTH,
            .DOWN => new_block.rect.y -= consts.BLOCK_WIDTH,
            .LEFT => new_block.rect.x += consts.BLOCK_WIDTH,
            .RIGHT => new_block.rect.x -= consts.BLOCK_WIDTH,
        }

        try self.tail.append(new_block);
    }

    fn didHitAWall(self: Game) bool {
        if (self.head.rect.x >= consts.WINDOW_WIDTH or self.head.rect.x <= 0 or self.head.rect.y >= consts.WINDOW_HEIGHT or self.head.rect.y <= 0) {
            return true;
        }

        return false;
    }

    fn didHitItTail(self: Game) bool {
        for (self.tail.items) |block| {
            if (utils.isColliding(self.head.rect, block.rect)) {
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
        if (utils.isColliding(self.head.rect, self.food.rect)) {
            try self.food.shuffle();
            try self.grow();
        }
    }

    pub fn update(self: *Game) !void {
        if (self.didHitAWall() or self.gameover) {
            return;
        }

        try self.handleFood();

        self.moveHeadBlock();
        for (self.tail.items) |_, index| {
            var direction_changed = false;
            var block = &self.tail.items[index];

            var queue_index = self.getQueueIndexByBlockIndex(index);

            if (index != 0 and utils.isColliding(self.head.rect, block.rect)) {
                self.gameover = true;
            }

            if (self.queue.items.len > 0 and queue_index < self.queue.items.len) {
                var target = &self.queue.items[queue_index];
                if (target != undefined and target.direction != block.direction) {
                    switch (target.direction) {
                        .UP, .DOWN => {
                            if (target.rect.x == block.rect.x) {
                                direction_changed = true;
                                block.direction = target.direction;
                                if (target.index == self.tail.items.len - 1) {
                                    self.removeQueueItemByBlockIndex(index);
                                } else {
                                    target.index += 1;
                                }
                            }
                        },
                        .LEFT, .RIGHT => {
                            if (target.rect.y == block.rect.y) {
                                block.direction = target.direction;
                                direction_changed = true;
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

    fn moveHeadBlock(self: *Game) void {
        self.length_since_last_turn += self.step_length;
        self.moveBlock(&self.head);
    }

    fn moveBlock(self: *Game, block: *Block) void {
        switch (block.direction) {
            .DOWN => block.rect.y += self.step_length,
            .UP => block.rect.y -= self.step_length,
            .RIGHT => block.rect.x += self.step_length,
            .LEFT => block.rect.x -= self.step_length,
        }
    }

    pub fn move(self: *Game, direction: Direction) !void {
        if (utils.getAxis(self.head.direction) == utils.getAxis(direction) or self.length_since_last_turn < self.head.rect.w) {
            return;
        }

        const direction_changed = self.head.direction != direction;
        self.head.direction = direction;

        if (direction_changed or self.queue.items.len == 0) {
            self.length_since_last_turn = 0;
            try self.queue.append(Queue{ .direction = direction, .index = 0, .rect = Rect{
                .x = self.head.rect.x,
                .y = self.head.rect.y,
                .w = self.head.rect.w,
                .h = self.head.rect.h,
            } });
        }
    }
};
