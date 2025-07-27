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
    assert(image != null);
    assert(image.width > 0 and image.height > 0);
    assert(image.pixels.len == image.height);
    for (image.pixels) |row| {
        assert(row.len == image.width);
    }

    switch (filter_type) {
        .grayscale => grayscale(image),
        .reflect => reflect(image),
        .blur => blur(image),
        .edges => edges(image),
    }

    assert(image.width > 0 and image.height > 0);
    assert(image.pixels.len == image.height);
    for (image.pixels) |row| {
        assert(row.len == image.width);
    }
}

fn grayscale(image: *Image) void {
    for (image.pixels) |row| {
        for (row) |*pixel| {
            const average_color: bmp.byte = @intCast((@as(bmp.word, pixel.blue) +
                @as(bmp.word, pixel.green) +
                @as(bmp.word, pixel.red)) / 3);

            assert(average_color >= 0 and average_color <= 255);
            pixel.* = .{
                .blue = average_color,
                .green = average_color,
                .red = average_color,
            };
        }
    }
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
