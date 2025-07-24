const std = @import("std");
const bmp = @import("bmp.zig");
const Allocator = std.mem.Allocator;

const assert = std.debug.assert;
const Image = @This();

height: u8,
width: u8,
bmp_file_header: bmp.BitMapFileHeader,
bmp_info_header: bmp.BitMapInfoHeader,
pixels: [][]bmp.RGBTriple,
allocator: Allocator,

pub fn init(allocator: Allocator, width: u8, height: u8) !Image {
}

pub fn deinit(self: *Image) void {
}

pub fn load_input_image(allocator: Allocator, file_path: []const u8) !Image {
}

pub fn save_output_image(self: *const Image, file_path: []const u8) !void {
}
