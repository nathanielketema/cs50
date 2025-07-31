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

// Swapping left pixels with right to get the mirror look
fn reflect(image: *Image) void {
    const width: usize = @intCast(image.width);
    for (image.pixels) |*row| {
        for (0..width / 2) |i| {
            const j = (width - 1) - i;
            std.mem.swap(bmp.RGBTriple, &row.*[i], &row.*[j]);
        }
    }
}

fn blur(image: *Image) void {
    const width: usize = @intCast(image.width);
    const height: usize = @intCast(image.height);
    
    var temp_image = image.copy() catch return;
    defer temp_image.deinit();

    assert(temp_image.height == image.height);
    assert(temp_image.width == image.width);

    for (0..height) |row| {
        for (0..width) |col| {
            var total_blue: u32 = 0;
            var total_green: u32 = 0;
            var total_red: u32 = 0;
            var count: u32 = 0;

            // Check all the positions in the 3x3 box around the current pixel
            for (0..3) |i| {
                for (0..3) |j| {
                    const neighbor_row: i32 = @as(i32, @intCast(row)) + @as(i32, @intCast(i)) - 1;
                    const neighbor_col: i32 = @as(i32, @intCast(col)) + @as(i32, @intCast(j)) - 1;

                    if (neighbor_row >= 0 and neighbor_row < image.height and
                        neighbor_col >= 0 and neighbor_col < image.width)
                    {
                        const nr: usize = @intCast(neighbor_row);
                        const nc: usize = @intCast(neighbor_col);

                        total_blue += temp_image.pixels[nr][nc].blue;
                        total_green += temp_image.pixels[nr][nc].green;
                        total_red += temp_image.pixels[nr][nc].red;
                        count += 1;
                    }
                }
            }
            assert(count > 0);
            assert(count <= 9);

            image.pixels[row][col].blue = @intCast(total_blue / count);
            image.pixels[row][col].green = @intCast(total_green / count);
            image.pixels[row][col].red = @intCast(total_red / count);
        }
    }
}

fn edges(image: *Image) void {
    _ = image;
}
