const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const testing = std.testing;

const block_size = 512;
const output_dir = "output";

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    assert(args.len > 0);
    if (args.len != 2) {
        print("Usage: zig run main.zig -- fileName\n", .{});
        return;
    }
    assert(args[1].len > 0);
    const input_path = args[1];

    const input_file = std.fs.cwd().openFile(input_path, .{}) catch {
        print("File not found!\n", .{});
        return;
    };
    defer input_file.close();
    try std.fs.Dir.makeDir(std.fs.cwd(), output_dir);


    var buffer: [block_size]u8 = undefined;
    var count: u8 = 0;

    // Read input_file in block_size bytes(blocks) until the end of input_file
    while (try input_file.reader().readAll(&buffer) == block_size) {
        assert(buffer.len == block_size);
        // Accept if JPEG starts with the first three bytes of 0xff, 0xd8, 0xff, 
        // and for the fourth byte, accept all bytes that start with 0xe
        if (buffer[0] == 0xff and buffer[1] == 0xd8 and buffer[2] == 0xff and
            (buffer[3] & 0xf0 == 0xe0))
        {
            // Create files of form 001.jpeg in the output directory
            const output_file_name = try std.fmt.allocPrint(allocator, "{s}/{d:0<3}.jpeg", .{output_dir, count});
            defer allocator.free(output_file_name);
            const output_file = try std.fs.cwd().createFile(output_file_name, .{});
            defer output_file.close();
            count += 1;

        } else {
        }
    }
}

test "check bitwise operation" {
    const buffer = [_]u8{ 0xe1, 0xe2, 0xe3, 0xe9, 0xee, 0xef };
    var ok: bool = true;

    // ok should stay true because buffer contains bytes that start with 0xe
    for (buffer) |byte| {
        if (byte & 0xf0 != 0xe0) {
            ok = false;
        }
    }

    try testing.expect(ok);
}
