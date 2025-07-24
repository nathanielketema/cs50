const std = @import("std");
const Image = @import("image.zig");
const filters = @import("filters.zig");

const assert = std.debug.assert;

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const args = std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // todo: validate 
    // todo: parse flag

    var image = Image.load_input_image(allocator, file_path: []const u8);
    defer image.deinit();

    try filters.apply_filter(&image, filter_type: FilterType);
    try image.save_output_image(file_path: []const u8);
}
