const std = @import("std");
const bmp = @import("bmp.zig");
const Image = @import("image.zig");
const assert = std.debug.assert;

pub const FilterType = enum {
    grayscale,
    reflect,
    blur,
    edges,
};

pub fn apply_filter(image: *Image, filter_type: FilterType) !void {
    assert(image.height > 0 and image.width > 0);
    assert(image.pixels.len >= 1);
    switch (filter_type) {
        .grayscale => grayscale(image),
        .reflect => reflect(image),
        .blur => blur(image),
        .edges => edges(image),
    }
}

fn grayscale(image: *Image) void {
    _ = image;
}

fn reflect(image: *Image) void {
    _ = image;
}

fn blur(image: *Image) void {
    _ = image;
}

fn edges(image: *Image) void {
    _ = image;
}
