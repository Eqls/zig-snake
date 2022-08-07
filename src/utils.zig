const std = @import("std");
const consts = @import("consts.zig");
const structs = @import("structs.zig");
const Coordinates = structs.Coordinates;
const Rect = structs.Rect;
const Direction = structs.Direction;
const Axis = structs.Axis;

pub fn isColliding(rect1: Rect, rect2: Rect) bool {
    if (rect1.x < rect2.x + rect2.w and rect1.x + rect1.w > rect2.x) {
        if (rect1.y < rect2.y + rect2.h and rect1.y + rect1.h > rect2.y) {
            return true;
        }
    }

    return false;
}

pub fn getAxis(direction: Direction) Axis {
    return switch (direction) {
        .DOWN, .UP => Axis.Y,
        .LEFT, .RIGHT => Axis.X,
    };
}

pub fn generateRandomCoordinates() !Coordinates {
    const prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    }).random();

    return Coordinates{
        .x = prng.intRangeAtMost(i32, 0, consts.WINDOW_WIDTH),
        .y = prng.intRangeAtMost(i32, 0, consts.WINDOW_HEIGHT),
    };
}
