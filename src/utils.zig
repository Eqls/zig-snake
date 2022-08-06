const structs = @import("structs.zig");
const Coordinates = structs.Coordinates;
const Square = structs.Square;

pub fn isColliding(sq1: Square, sq2: Square) bool {
    if (sq1.x + sq1.w / 2 > sq2.x - sq2.w / 2 or sq1.x - sq1.w / 2 < sq2.x + sq2.w / 2 or sq1.y + sq1.h / 2 > sq2.y - sq2.h or sq1.y - sq1.h / 2 < sq1.y + sq1.h / 2) {
        return true;
    }

    return false;
}
