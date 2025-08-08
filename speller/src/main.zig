const std = @import("std");
const HashTable = @import("HashTable.zig");
const print = std.debug.print;
const testing = std.testing;
const assert = std.debug.assert;

pub const max_word_length = 45;
pub const bucket_size = 160_000;
pub const default_dictionary_path = "../data/dictionaries/large";

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Args is either two or three
    if (args.len != 2 and args.len != 3) {
        print("Usage: zig build run -- [Dictionary] text\n", .{});
        return;
    }

    var hash_table: HashTable = .init(allocator);
    defer hash_table.deinit();

    const dictionary_path = if (args.len == 2) default_dictionary_path else args[1];
    var dictionary_dir: std.fs.Dir = undefined;
    const dictionary_file = undefined;

    if (std.mem.eql(u8, dictionary_path, default_dictionary_path)) {
        dictionary_dir = try std.fs.Dir.openDir(std.fs.cwd(), dictionary_path, .{});
        dictionary_file = std.fs.cwd().openFile(dictionary_path[22..], .{}) catch {
            print("Could not load {s}\n", .{dictionary_path});
            return;
        };
    } else {
        dictionary_file = std.fs.cwd().openFile(dictionary_path, .{}) catch {
            print("Could not load {s}\n", .{dictionary_path});
            return;
        };
    }
    defer std.fs.Dir.close(dictionary_path);
    defer dictionary_file.close();

    var dictionary = try dictionary_file.reader().readUntilDelimiterAlloc(
        allocator,
        '\n',
        max_word_length,
    );
    while (true) {
        try hash_table.load(dictionary);
        dictionary = try dictionary_file.reader().readUntilDelimiterAlloc(
            allocator,
            '\n',
            max_word_length,
        );
        if (dictionary.len == 0) {
            break;
        }
    }
}
