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

            image.pixels[row][col] = .{
                .blue = @intCast(total_blue / count),
                .green = @intCast(total_green / count),
                .red = @intCast(total_red / count),
            };
        }
    }
}

fn edges(image: *Image) void {
    const height: usize = @intCast(image.height);
    const width: usize = @intCast(image.width);

    var temp_image = image.copy() catch return;
    defer temp_image.deinit();

    assert(temp_image.height == image.height);
    assert(temp_image.width == image.width);

    // Darken the edges of the image
    for (0..height) |row| {
        for (0..width) |col| {
            if (row == 0 or row == height - 1 or
                col == 0 or col == width - 1)
            {
                temp_image.pixels[row][col] = .{
                    .blue = 0,
                    .green = 0,
                    .red = 0,
                };
            }
        }
    }

    // Sobels kernel
    const kernel = &.{
        .Gx = [3][3]i8{
            .{ -1, 0, 1 },
            .{ -2, 0, 2 },
            .{ -1, 0, 1 },
        },
        .Gy = [3][3]i8{
            .{ -1, -2, -1 },
            .{ 0, 0, 0 },
            .{ 1, 2, 1 },
        },
    };

    for (0..height) |row| {
        for (0..width) |col| {
            var total_blue_gx: i32 = 0;
            var total_blue_gy: i32 = 0;
            var total_green_gx: i32 = 0;
            var total_green_gy: i32 = 0;
            var total_red_gx: i32 = 0;
            var total_red_gy: i32 = 0;

            // A loop to access all the pixels in the 3x3 box
            for (0..3) |i| {
                for (0..3) |j| {
                    const neighbor_row: i32 = @as(i32, @intCast(row)) - @as(i32, @intCast(i)) + 1;
                    const neighbor_col: i32 = @as(i32, @intCast(col)) - @as(i32, @intCast(j)) + 1;

                    // Check if the neighboring row and col is withing the bounds of the image
                    if (neighbor_row > 0 and neighbor_row < image.height - 1 and
                        neighbor_col > 0 and neighbor_col < image.width - 1)
                    {
                        const nr: usize = @intCast(neighbor_row);
                        const nc: usize = @intCast(neighbor_col);

                        total_blue_gx += @as(i32, @intCast(temp_image.pixels[nr][nc].blue)) *
                            kernel.Gx[2 - i][2 - j];
                        total_blue_gy += @as(i32, @intCast(temp_image.pixels[nr][nc].blue)) *
                            kernel.Gy[2 - i][2 - j];

                        total_green_gx += @as(i32, @intCast(temp_image.pixels[nr][nc].green)) *
                            kernel.Gx[2 - i][2 - j];
                        total_green_gy += @as(i32, @intCast(temp_image.pixels[nr][nc].green)) *
                            kernel.Gy[2 - i][2 - j];

                        total_red_gx += @as(i32, @intCast(temp_image.pixels[nr][nc].red)) *
                            kernel.Gx[2 - i][2 - j];
                        total_red_gy += @as(i32, @intCast(temp_image.pixels[nr][nc].red)) *
                            kernel.Gy[2 - i][2 - j];
                    }
                }
            }

            const total_blue = std.math.clamp(std.math.sqrt((@as(u64, @intCast(total_blue_gx * 
            total_blue_gx))) + @as(u64, @intCast(total_blue_gy * total_blue_gy))), 0, 255);

            const total_green = std.math.clamp(std.math.sqrt((@as(u64, @intCast(total_green_gx * 
            total_green_gx))) + @as(u64, @intCast(total_green_gy * total_green_gy))), 0, 255);

            const total_red = std.math.clamp(std.math.sqrt((@as(u64, @intCast(total_red_gx * 
            total_red_gx))) + @as(u64, @intCast(total_red_gy * total_red_gy))), 0, 255);

            const final_blue: u8 = @intCast(total_blue);
            const final_green: u8 = @intCast(total_green);
            const final_red: u8 = @intCast(total_red);

            assert(final_blue >= 0 and final_blue <= 255);
            assert(final_green >= 0 and final_green <= 255);
            assert(final_red >= 0 and final_red <= 255);

            image.pixels[row][col] = .{
                .blue = final_blue,
                .green = final_green,
                .red = final_red,
            };
        }
    }
}
