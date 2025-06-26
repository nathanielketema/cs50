const std = @import("std");
const testing = std.testing;

const print = std.debug.print;

const Score = struct {
    letter: u8 = undefined,
    value: u8 = undefined,
};

const scoring = [_]Score{
    .{ .letter = 'A', .value = 1 },  .{ .letter = 'B', .value = 3 },
    .{ .letter = 'C', .value = 3 },  .{ .letter = 'D', .value = 2 },
    .{ .letter = 'E', .value = 1 },  .{ .letter = 'F', .value = 4 },
    .{ .letter = 'G', .value = 2 },  .{ .letter = 'H', .value = 4 },
    .{ .letter = 'I', .value = 1 },  .{ .letter = 'J', .value = 8 },
    .{ .letter = 'K', .value = 5 },  .{ .letter = 'L', .value = 1 },
    .{ .letter = 'M', .value = 3 },  .{ .letter = 'N', .value = 1 },
    .{ .letter = 'O', .value = 1 },  .{ .letter = 'P', .value = 3 },
    .{ .letter = 'Q', .value = 10 }, .{ .letter = 'R', .value = 1 },
    .{ .letter = 'S', .value = 1 },  .{ .letter = 'T', .value = 1 },
    .{ .letter = 'U', .value = 1 },  .{ .letter = 'V', .value = 4 },
    .{ .letter = 'W', .value = 4 },  .{ .letter = 'X', .value = 8 },
    .{ .letter = 'Y', .value = 4 },  .{ .letter = 'Z', .value = 10 },
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var buffer: [30]u8 = undefined;

    print("Player 1: ", .{});
    const player1 = try stdin.readUntilDelimiterOrEof(&buffer, '\n');

    const player1Score = getScore(player1 orelse return);

    print("Player 2: ", .{});
    const player2 = try stdin.readUntilDelimiterOrEof(&buffer, '\n');
    const player2Score = getScore(player2.?); // player2.? -> player2 orelse unreachable

    if (player1Score > player2Score) {
        print("Player 1 wins\n", .{});
    } else if (player1Score < player2Score) {
        print("Player 2 wins\n", .{});
    } else {
        print("Tie!\n", .{});
    }
}

fn getScore(word: []const u8) u8 {
    var sum: u8 = 0;
    for (word) |w| {
        const l: u8 = std.ascii.toUpper(w);
        for (scoring) |s| {
            if (l == s.letter) {
                sum += s.value;
            }
        }
    }
    return sum;
}

test "first test" {
    const a = getScore("Nathaniel");
    const b = getScore("Ketema");
    try testing.expect((a == b));
}

test "getScore returns correct values for single letters" {
    // Test all letters in the scoring table
    for (scoring) |s| {
        const letter = [_]u8{s.letter};
        try testing.expectEqual(s.value, getScore(&letter));

        // Also test lowercase version
        const lower_letter = [_]u8{std.ascii.toLower(s.letter)};
        try testing.expectEqual(s.value, getScore(&lower_letter));
    }
}

test "getScore handles empty string" {
    const empty = "";
    try testing.expectEqual(@as(u8, 0), getScore(empty));
}

test "getScore calculates correct sums for words" {
    // Corrected test values based on actual letter scores
    try testing.expectEqual(@as(u8, 13), getScore("zig")); // Z(10) + I(1) + G(2) = 13
    try testing.expectEqual(@as(u8, 22), getScore("quiz")); // Q(10) + U(1) + I(1) + Z(10) = 22
    try testing.expectEqual(@as(u8, 29), getScore("jazz")); // J(8) + A(1) + Z(10) + Z(10) = 29
    try testing.expectEqual(@as(u8, 12), getScore("program")); // P(3) + R(1) + O(1) + G(2) + R(1) + A(1) + M(3) = 12

    // Test with mixed case
    try testing.expectEqual(@as(u8, 13), getScore("Zig"));
    try testing.expectEqual(@as(u8, 13), getScore("zIg"));
    try testing.expectEqual(@as(u8, 13), getScore("ziG"));
}

test "getScore ignores non-alphabetic characters" {
    try testing.expectEqual(@as(u8, 0), getScore("123"));
    try testing.expectEqual(@as(u8, 0), getScore("!@#"));
    try testing.expectEqual(@as(u8, 6), getScore("h3ll0!")); // "hll" = 4 + 1 + 1 = 6
}

test "getScore handles unknown letters" {
    try testing.expectEqual(@as(u8, 0), getScore("å"));
    try testing.expectEqual(@as(u8, 0), getScore("ß"));
}

test "getScore handles long words" {
    const long_word = "supercalifragilisticexpialidocious";
    // Calculate expected score manually
    const expected_score: u8 =
        1 + // S
        1 + // U
        3 + // P
        1 + // E
        1 + // R
        3 + // C
        1 + // A
        1 + // L
        1 + // I
        4 + // F
        1 + // R
        1 + // A
        2 + // G
        1 + // I
        1 + // L
        1 + // I
        1 + // S
        1 + // T
        1 + // I
        3 + // C
        1 + // E
        8 + // X
        3 + // P
        1 + // I
        1 + // A
        1 + // L
        1 + // I
        2 + // D
        1 + // O
        3 + // C
        1 + // I
        1 + // O
        1 + // U
        1; // S

    try testing.expectEqual(expected_score, getScore(long_word));
}
