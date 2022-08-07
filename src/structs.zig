pub const Coordinates = struct {
    x: i32,
    y: i32,
};

pub const Rect = struct {
    x: i32,
    y: i32,
    w: i32,
    h: i32,
};

pub const Axis = enum {
    Y,
    X,
};

pub const Direction = enum {
    UP,
    DOWN,
    LEFT,
    RIGHT,
};
