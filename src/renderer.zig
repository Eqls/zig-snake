const std = @import("std");
const c = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_ttf.h");
});

const consts = @import("consts.zig");
const WINDOW_WIDTH = consts.WINDOW_WIDTH;
const WINDOW_HEIGHT = consts.WINDOW_HEIGHT;

const Rect = @import("structs.zig").Rect;
const Coordinates = @import("structs.zig").Coordinates;

pub const Renderer = struct {
    renderer: ?*c.SDL_Renderer,
    window: ?*c.SDL_Window,

    pub fn init() !Renderer {
        _ = c.SDL_Init(c.SDL_INIT_VIDEO);
        _ = c.TTF_Init();

        var window = c.SDL_CreateWindow(
            "hello gamedev",
            c.SDL_WINDOWPOS_CENTERED,
            c.SDL_WINDOWPOS_CENTERED,
            WINDOW_WIDTH,
            WINDOW_HEIGHT,
            0,
        );

        return Renderer{
            .window = window,
            .renderer = c.SDL_CreateRenderer(window, 0, c.SDL_RENDERER_PRESENTVSYNC),
        };
    }

    pub fn deinit(self: *Renderer) void {
        c.SDL_Quit();
        c.TTF_Quit();
        c.SDL_DestroyWindow(self.window);
        c.SDL_DestroyRenderer(self.renderer);
    }

    pub fn drawRect(self: Renderer, rect: Rect, color: @Vector(4, u8)) void {
        _ = c.SDL_SetRenderDrawColor(self.renderer, color[0], color[1], color[2], color[3]);
        _ = c.SDL_RenderFillRect(self.renderer, &c.SDL_Rect{
            .x = rect.x,
            .y = rect.y,
            .w = rect.w,
            .h = rect.h,
        });
    }

    pub fn drawText(self: *Renderer, value: []const u8, pos: Coordinates, color: @Vector(4, u8)) void {
        // this opens a font and sets a size
        var font = c.TTF_OpenFont("/Users/armandasgarsva/Library/Fonts/Iosevka-Bold.ttc", 20) orelse {
            c.SDL_Log("Unable to load font: %s", c.TTF_GetError());
            return;
        };
        defer c.TTF_CloseFont(font);

        // this is the color in rgb format,
        // maxing out all would give you the color white,
        // and it will be your text's color
        var _color = c.SDL_Color{ .r = color[0], .g = color[1], .b = color[2], .a = color[3] };

        // as TTF_RenderText_Solid could only be used on
        // SDL_Surface then you have to create the surface first
        var surface_message =
            c.TTF_RenderText_Solid(font, value.ptr, _color);
        defer c.SDL_FreeSurface(surface_message);

        // now you can convert it into a texture
        var message = c.SDL_CreateTextureFromSurface(self.renderer, surface_message);
        defer c.SDL_DestroyTexture(message);

        var message_rect = c.SDL_Rect{
            .x = pos.x,
            .y = pos.y,
            .w = surface_message.*.w,
            .h = surface_message.*.h,
        };

        // (0,0) is on the top left of the window/screen,
        // think a rect as the text's box,
        // that way it would be very simple to understand

        // Now since it's a texture, you have to put RenderCopy
        // in your game loop area, the area where the whole code executes

        // you put the renderer's name first, the Message,
        // the crop size (you can ignore this if you don't want
        // to dabble with cropping), and the rect which is the size
        // and coordinate of your texture
        _ = c.SDL_RenderCopy(self.renderer, message, null, &message_rect);
    }

    pub fn getTicks(_: Renderer) u32 {
        return c.SDL_GetTicks();
    }

    pub fn clearFrame(self: Renderer) void {
        _ = c.SDL_SetRenderDrawColor(self.renderer, 0xff, 0xff, 0xff, 0xff);
        _ = c.SDL_RenderClear(self.renderer);
    }

    pub fn redraw(self: Renderer) void {
        _ = c.SDL_RenderPresent(self.renderer);
    }
};
