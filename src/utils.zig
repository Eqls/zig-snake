const std = @import("std");
const consts = @import("consts.zig");
const structs = @import("structs.zig");
const Coordinates = structs.Coordinates;
const Rect = structs.Rect;
const Direction = structs.Direction;
const Axis = structs.Axis;

pub fn isColliding(sq1: Rect, sq2: Rect) bool {
    std.debug.print("{}\n", .{@divTrunc(sq1.w, 2)});
    if (sq1.x + @divTrunc(sq1.w, 2) >= sq2.x - @divTrunc(sq2.w, 2) and sq1.x - @divTrunc(sq1.w, 2) <= sq2.x + @divTrunc(sq2.w, 2)) {
        if (sq1.y + @divTrunc(sq1.h, 2) >= sq2.y - sq2.h and sq1.y - @divTrunc(sq1.h, 2) <= sq2.y + @divTrunc(sq2.h, 2)) {
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
