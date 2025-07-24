const std = @import("std");
const stdin = std.io.getStdIn().reader();
const print = std.debug.print;
const testing = std.testing;
const assert = std.debug.assert;

const header_size = 44;
const data_size = 2;

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 4) {
        print("Usage: zig run input_file.wav output_file.wav factor\n", .{});
        return;
    }

    const input_file_path = args[1];

    const output_file_path = args[2];
    if (!std.mem.endsWith(u8, output_file_path, ".wav")) {
        print(
            "Output file <{s}> must end in \".wav\"\n",
            .{output_file_path},
        );
        return;
    }
    // If it doesn't have a filename
    if (output_file_path.len < 5) {
        print("Output file <{s}> must have a filename\n", .{output_file_path});
        return;
    }

    const factor = std.fmt.parseFloat(f16, args[3]) catch {
        print("Factor <{s}> is not a number\n", .{args[3]});
        return;
    };
    if (factor == 0.0) {
        print("Factor cannot be zero\n", .{});
        return;
    }

    const input_file_wav = std.fs.cwd().openFile(
        input_file_path,
        .{ .mode = .read_only },
    ) catch {
        print("File <{s}> not found!\n", .{input_file_path});
        return;
    };
    defer input_file_wav.close();

    const output_file_wav = try std.fs.cwd().createFile(output_file_path, .{});
    defer output_file_wav.close();

    var header: [header_size]u8 = undefined;
    try input_file_wav.seekTo(0);
    assert(try input_file_wav.readAll(&header) == header_size);
    try output_file_wav.writeAll(&header);

    var data: [data_size]u8 = undefined;
    while (try input_file_wav.readAll(&data) == data_size) {
        assert(data.len == data_size);
        
        var value: f16 = @bitCast(data);
        value = value * factor;
        var data_changed: [data_size]u8 = @bitCast(value);
        try output_file_wav.writeAll(&data_changed);
    }
}

test "test name" {}
