const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const testing = std.testing;

const block_size = 512;
const output_dir = "output";

const WriteFile = struct {
    file_name: []u8,
    file: std.fs.File,
    allocator: std.mem.Allocator,

    fn init(allocator: std.mem.Allocator) WriteFile {
        return .{
            .file_name = undefined,
            .file = undefined,
            .allocator = allocator,
        };
    }

    fn deinit(self: *WriteFile) void {
        self.allocator.free(self.file_name);
        self.file.close();
    }

    fn new_file_name(self: *WriteFile, comptime fmt: []const u8, args: anytype) !void {
        self.file_name = try std.fmt.allocPrint(self.allocator, fmt, args);
    }

    fn create_file(self: *WriteFile) !void {
        self.file = std.fs.cwd().createFile(self.file_name, .{}) catch {
            print("{s} cannot be created\n", .{self.file_name});
            return;
        };
    }

    fn write_file(self: *WriteFile, bytes: []const u8) !void {
        try self.file.writeAll(bytes);
    }
};

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

    std.fs.Dir.makeDir(std.fs.cwd(), output_dir) catch |err| {
        switch (err) {
            error.PathAlreadyExists => {},
            else => return err,
        }
    };

    var buffer: [block_size]u8 = undefined;
    var count: u32 = 0;
    var found: bool = false;
    var output_jpegs = WriteFile.init(allocator);
    defer output_jpegs.deinit();

    // Read input_file in block_size bytes(blocks) until the end of input_file
    while (try input_file.reader().readAll(&buffer) == block_size) {
        assert(buffer.len == block_size);
        // Accept if JPEG starts with the first three bytes of 0xff, 0xd8, 0xff,
        // and for the fourth byte, accept all bytes that start with 0xe
        if (buffer[0] == 0xff and buffer[1] == 0xd8 and buffer[2] == 0xff and
            (buffer[3] & 0xf0 == 0xe0))
        {
            if (found) {
                output_jpegs.deinit();
            }

            count += 1;
            found = true;

            // Create files of form 001.jpeg in the output directory
            try output_jpegs.new_file_name(
                "{s}/{d:0>3}.jpeg",
                .{ output_dir, count },
            );
            try output_jpegs.create_file();
            try output_jpegs.write_file(&buffer);
        } else {
            if (found) {
                try output_jpegs.write_file(&buffer);
            }
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

test "file name check" {
    const allocator = std.testing.allocator;

    for (0..21) |count| {
        const name = try std.fmt.allocPrint(
            allocator,
            "{s}/{d:0>3}.jpeg",
            .{ output_dir, count },
        );

        print("name: {s}\n", .{name});
        allocator.free(name);
    }
}
