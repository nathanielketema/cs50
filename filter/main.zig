const std = @import("std");
const Image = @import("image.zig");
const filters = @import("filters.zig");
const FilterType = filters.FilterType;
const print = std.debug.print;
const assert = std.debug.assert;

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    assert(args.len >= 1);
    if (args.len != 4) {
        print("Usage: zig run main.zig -- input.bmp [flag] output.bmp\n", .{});
        return;
    }

    const input_file = args[1];
    const filter_flag = args[2];
    const output_file = args[3];

    const filter_type = parse_filter(filter_flag) catch {
        print("Invalid flag.\n", .{});
        print(
            \\ Available flags:
            \\     -g, --grayscale
            \\     -r, --reflect
            \\     -b, --blur
            \\     -e, --edges 
        , .{});
    };

    var image = try Image.load_input_image(allocator, input_file);
    defer image.deinit();

    assert(image.width > 0 and image.height > 0);
    assert(image.pixels.len >= 1);

    try filters.apply_filter(&image, filter_type);
    try image.save_output_image(output_file);
}

fn parse_filter(flag: []const u8) !FilterType {
    assert(flag.len > 0);
    if (std.mem.eql(u8, flag, "-g") or std.mem.eql(u8, flag, "--grayscale")) {
        return .grayscale;
    }
    if (std.mem.eql(u8, flag, "-r") or std.mem.eql(u8, flag, "--reflect")) {
        return .reflect;
    }
    if (std.mem.eql(u8, flag, "-b") or std.mem.eql(u8, flag, "--blur")) {
        return .blur;
    }
    if (std.mem.eql(u8, flag, "-e") or std.mem.eql(u8, flag, "--edges")) {
        return .edges;
    }
    return anyerror;
}
