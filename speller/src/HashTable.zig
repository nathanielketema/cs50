const std = @import("std");
const assert = std.debug.assert;
const print = std.debug.print;
const testing = std.testing;

// todo: case insensitivity

const max_word_length = 45;
const bucket_size = 26; // todo: change later

number_of_words_stored: u32,
hash_table: [bucket_size]?*Node,
allocator: std.mem.Allocator,

const Node = struct {
    word: []const u8,
    next: ?*Node,
};

fn hash(word: []const u8) u32 {
    _ = word;
    return 2;
}

const Self = @This();

fn init(allocator: std.mem.Allocator) Self {
    return .{
        .number_of_words_stored = 0,
        .hash_table = .{null} ** bucket_size,
        .allocator = allocator,
    };
}

fn deinit(self: *Self) void {
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
fn load(self: *Self, dictionary: []const u8) !void {
    assert(dictionary.len > 0);
    assert(dictionary.len <= max_word_length);

    const key = hash(dictionary);
    assert(key >= 0);
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
        self.number_of_words_stored += 1;
    } else {
        self.hash_table[key] = node;
        self.number_of_words_stored += 1;
    }
}

/// Returns number of words in dictionary
fn size(self: Self) u32 {
    return self.number_of_words_stored;
}

fn check(self: Self, word: []const u8) bool {
    const key = hash(word);

    var current: ?*Node = self.hash_table[key];
    while (current) |node| {
        current = node.next;
        if (std.mem.eql(u8, word, node.word)) {
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

    try testing.expect(foo.check("hi"));
    try testing.expect(!foo.check("bar"));
}
