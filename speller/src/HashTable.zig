const std = @import("std");
const main = @import("main.zig");
const assert = std.debug.assert;
const print = std.debug.print;
const testing = std.testing;
const max_word_length = main.max_word_length;
const bucket_size = main.bucket_size;

// The name size is already used by a method
number_of_words_stored: u32,
hash_table: [bucket_size]?*Node,
allocator: std.mem.Allocator,

const Node = struct {
    word: []const u8,
    next: ?*Node,
};

fn hash(word: []const u8) u32 {
    assert(word.len <= max_word_length);
    var key: u32 = undefined;
    for (word, 0..) |c, i| {
        key = @as(u32, @intCast(c)) * 23 * @as(u32, @intCast(i));
    }

    return @mod(key, bucket_size);
}

const Self = @This();

pub fn init(allocator: std.mem.Allocator) Self {
    return .{
        .number_of_words_stored = 0,
        .hash_table = .{null} ** bucket_size,
        .allocator = allocator,
    };
}

pub fn deinit(self: *Self) void {
    for (&self.hash_table) |*head| {
        var current: ?*Node = head.*;
        while (current) |node| {
            current = node.next;
            self.allocator.destroy(node);
        }
        head.* = null;
    }
}

/// Loads dictionary into memory
pub fn load(self: *Self, dictionary: []const u8) !void {
    // Program assumes the below to be a requirement
    assert(dictionary.len > 0);
    assert(dictionary.len <= max_word_length);

    const key = hash(dictionary);
    assert(key < bucket_size);

    const node = try self.allocator.create(Node);
    node.* = .{
        .word = dictionary,
        .next = null,
    };

    // If bucket is not empty
    if (self.hash_table[key]) |*head| {
        node.next = head.*;
        head.* = node;
    } else {
        self.hash_table[key] = node;
    }
    self.number_of_words_stored += 1;
}

/// Returns number of words in dictionary
pub fn size(self: Self) u32 {
    return self.number_of_words_stored;
}

pub fn check(self: Self, word_to_check: []const u8) bool {
    assert(word_to_check.len > 0);
    assert(word_to_check.len <= max_word_length);

    // check assumes the hash table store only lowercase words
    var word: [max_word_length]u8 = undefined;
    for (word_to_check, 0..) |c, i| {
        word[i] = std.ascii.toLower(c);
    }

    const key = hash(word[0..word_to_check.len]);
    assert(key < bucket_size);

    var current: ?*Node = self.hash_table[key];
    while (current) |node| {
        current = node.next;
        if (std.mem.eql(u8, word[0..word_to_check.len], node.word)) {
            return true;
        }
    }

    return false;
}

test "test" {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    var foo: @This() = .init(allocator);
    defer foo.deinit();

    try testing.expect(foo.number_of_words_stored == 0);

    try foo.load("hi");
    try foo.load("hello");
    try testing.expect(foo.number_of_words_stored == 2);

    try testing.expect(foo.check("Hi"));
    try testing.expect(!foo.check("bar"));
    try testing.expect(foo.check("hElLo"));
    try testing.expect(foo.check("hello"));
}
