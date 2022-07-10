const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub fn main() anyerror!void {
    var flr: i8 = 5;
    std.debug.print("Hello World!{:2} {:1} ", .{ flr, @as(u32, 1234) });
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
