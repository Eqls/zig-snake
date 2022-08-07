const structs = @import("structs.zig");
const Rect = structs.Rect;
const utils = @import("utils.zig");

pub fn _shuffle() !Rect {
    const randPos = try utils.generateRandomCoordinates();

    return Rect{
        .x = randPos.x,
        .y = randPos.y,
        .w = 15,
        .h = 15,
    };
}

pub const Food = struct {
    rect: Rect,

    pub fn init() !Food {
        return Food{
            .rect = try _shuffle(),
        };
    }

    pub fn shuffle(self: *Food) !void {
        self.rect = try _shuffle();
    }
};
