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
    switch (filter_type) {
        .grayscale => grayscale(image),
        .reflect => reflect(image),
        .blur => blur(image),
        .edges => edges(image),
        else => unreachable,
    }
}

fn grayscale(image: *Image) void {
}

fn reflect(image: *Image) void {
}

fn blur(image: *Image) void {
}

fn edges(image: *Image) void {
}
