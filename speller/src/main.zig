const std = @import("std");
const HashTable = @import("HashTable.zig");
const stdout = std.io.getStdOut().writer();
const testing = std.testing;
const assert = std.debug.assert;

pub const max_word_length = 45;
pub const bucket_size = 160_000;

const default_dictionary_path = "data/dictionaries/large";

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Args is either two or three
    if (args.len != 2 and args.len != 3) {
        try stdout.print("Usage: zig build run -- [Dictionary] text\n", .{});
        return;
    }

    var dictionary_path: []const u8 = undefined;
    var text_path: []const u8 = undefined;
    // If a dictionary is not provided, use the default dictionary
    if (args.len == 2) {
        dictionary_path = default_dictionary_path;
        text_path = args[1];
    } else { // args.len == 3
        dictionary_path = args[1];
        text_path = args[2];
    }

    var time_load: f64 = 0.0;
    var time_check: f64 = 0.0;
    var time_size: f64 = 0.0;
    var time_unload: f64 = 0.0;

    const load_start = std.time.nanoTimestamp();

    // Open the dictionary file
    const dictionary = std.fs.cwd().openFile(dictionary_path, .{}) catch {
        try stdout.print("Could not open {s}\n", .{dictionary_path});
        return;
    };
    defer dictionary.close();

    var hash_table: HashTable = .init(allocator);
    defer hash_table.deinit();

    // To avoid syscalls, which are very slow
    var buffered_dict_reader = std.io.bufferedReader(dictionary.reader());

    var dictionary_data: [max_word_length]u8 = undefined;
    while (true) {
        // fixedBufferStream() turns a byte(in our case dictionary_data) into an I/O writer, reader, etc..
        // This will help us use streamUntilDelimiter to write to our given byte
        var out_stream = std.io.fixedBufferStream(&dictionary_data);
        const reader = buffered_dict_reader.reader();

        reader.streamUntilDelimiter(out_stream.writer(), '\n', null) catch |err| {
            switch (err) {
                error.EndOfStream => break,
                else => return err,
            }
        };
        if (out_stream.getWritten().len == 0) {
            break;
        }

        const word_copy = try allocator.dupe(u8, out_stream.getWritten());
        try hash_table.load(word_copy);
    }

    const load_end = std.time.nanoTimestamp();
    time_load = calculate_time_diff(load_start, load_end);

    // Open text file
    const text = std.fs.cwd().openFile(text_path, .{}) catch {
        try stdout.print("Could not open {s}\n", .{text_path});
        return;
    };
    defer text.close();

    // Prepare to report misspellings
    try stdout.print("\nMISSPELLED WORDS\n\n", .{});

    // Spel-check variables
    var index: usize = 0;
    var misspellings: u32 = 0;
    var words: u32 = 0;
    var word: [max_word_length]u8 = undefined;

    var buffered_text_reader = std.io.bufferedReader(text.reader());
    const text_reader = buffered_text_reader.reader();

    while (true) {
        const c = text_reader.readByte() catch |err| {
            switch (err) {
                error.EndOfStream => break,
                else => return err,
            }
        };

        if (std.ascii.isAlphabetic(c) or (c == '\'' and index > 0)) {
            if (index >= max_word_length) {
                while (true) {
                    const next_c = text_reader.readByte() catch |err| {
                        switch (err) {
                            error.EndOfStream => break,
                            else => return err,
                        }
                    };
                    if (!std.ascii.isAlphabetic(next_c)) break;
                }
                index = 0;
            } else {
                word[index] = c;
                index += 1;
            }
        } else if (std.ascii.isDigit(c)) {
            while (true) {
                const next_c = text_reader.readByte() catch |err| {
                    switch (err) {
                        error.EndOfStream => break,
                        else => return err,
                    }
                };
                if (!std.ascii.isAlphanumeric(next_c)) break;
            }
            index = 0;
        } else if (index > 0) {
            if (index < max_word_length) {
                word[index] = 0;
            }
            words += 1;

            const check_start = std.time.nanoTimestamp();
            const misspelled = !hash_table.check(word[0..index]);
            const check_end = std.time.nanoTimestamp();

            time_check += calculate_time_diff(check_start, check_end);

            if (misspelled) {
                try stdout.print("{s}\n", .{word[0..index]});
                misspellings += 1;
            }

            index = 0;
        }
    }

    const size_start = std.time.nanoTimestamp();
    const dictionary_size = hash_table.size();
    const size_end = std.time.nanoTimestamp();
    time_size = calculate_time_diff(size_start, size_end);

    const unload_start = std.time.nanoTimestamp();
    const unload_end = std.time.nanoTimestamp();

    time_unload = calculate_time_diff(unload_start, unload_end);

    try stdout.print("\nWORDS MISSPELLED:     {d}\n", .{misspellings});
    try stdout.print("WORDS IN DICTIONARY:  {d}\n", .{dictionary_size});
    try stdout.print("WORDS IN TEXT:        {d}\n", .{words});
}

fn calculate_time_diff(start_time: i128, end_time: i128) f64 {
    assert(start_time <= end_time);
    const diff_ns = end_time - start_time;
    return @as(f64, @floatFromInt(diff_ns)) / 1_000_000_000.0;
}
