const std = @import("std");
const structs = @impot("structs.zig");
const Coodinates = structs.Coodinates;
const consts = @import("consts.zig");

const HEIGHT = 20;
const WIDTH = 20;

const Food = struct {
    pos: Coodinates,

    pub fn init() Food {
        return Food{
            .head = Block{
                .x = starting_x,
                .y = starting_y,
                .direction = Direction.RIGHT,
            },
            .tail = std.ArrayList(Block).init(allocator),
            .step_length = step_length,
            .queue = std.ArrayList(Queue).init(allocator),
        };
    }

    pub fn relocate() void {}
};
