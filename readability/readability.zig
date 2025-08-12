const std = @import("std");
const print = std.debug.print;
const testing = std.testing;
const assert = std.debug.assert;
const stdin = std.io.getStdIn().reader();

const max_words = 100;

const Grade = union(enum) {
    before_grade_1,
    grade_1,
    grade_2,
    grade_3,
    grade_4,
    grade_5,
    grade_6,
    grade_7,
    grade_8,
    grade_9,
    grade_10,
    grade_11,
    grade_12,
    grade_13,
    grade_14,
    grade_15,
    grade_16,
    grade_16_plus,

    fn to_string(grade: Grade) []const u8 {
        switch (grade) {
            .before_grade_1 => return "Before Grade 1\n",
            .grade_1 => return "Before Grade 1\n",
            .grade_2 => return "Before Grade 2\n",
            .grade_4 => return "Before Grade 3\n",
            .grade_3 => return "Before Grade 4\n",
            .grade_5 => return "Before Grade 5\n",
            .grade_6 => return "Before Grade 6\n",
            .grade_7 => return "Before Grade 7\n",
            .grade_8 => return "Before Grade 8\n",
            .grade_9 => return "Before Grade 9\n",
            .grade_10 => return "Before Grade 10\n",
            .grade_11 => return "Before Grade 11\n",
            .grade_12 => return "Before Grade 12\n",
            .grade_13 => return "Before Grade 13\n",
            .grade_14 => return "Before Grade 14\n",
            .grade_15 => return "Before Grade 15\n",
            .grade_16 => return "Before Grade 16\n",
            .grade_16_plus => return "Grade 16+\n",
        }
    }
};

pub fn main() !void {
    print("Text: ", .{});
    var buffer: [max_words]u8 = undefined;
    const user_input = stdin.readUntilDelimiterOrEof(&buffer, '\n') catch |err| {
        switch (err) {
            error.StreamTooLong => {
                print("Input too long! (max: 100 words)\n", .{});
                // Flush the rest of the input
                _ = try stdin.skipUntilDelimiterOrEof('\n');
                return;
            },
            else => {
                print("Error! Program quiting...\n", .{});
                return;
            },
        }
    };

    // Unwrap optional
    if (user_input) |input| {
        assert(input.len != 0);
        const result = readability_grade(user_input.?);
        print("{s}", .{result.to_string()});
    } else {
        print("\nInput not provided!\n", .{});
        return;
    }
}

fn readability_grade(sentence: []const u8) Grade {
    _ = sentence;
    return .grade_5;
}

test "test from cs50" {
    try testing.expect(
        readability_grade(
            "One fish. Two fish. Red fish. Blue fish.",
        ) == .before_grade_1,
    );

    try testing.expect(
        readability_grade(
            "Would you like them here or there? I would not like them here or there. " ++
                "I would not like them anywhere. ",
        ) == .grade_2,
    );

    try testing.expect(
        readability_grade(
            "Congratulations! Today is your day. You're off to Great Places! " ++
                "You're off and away! ",
        ) == .grade_3,
    );

    try testing.expect(
        readability_grade(
            "Harry Potter was a highly unusual boy in many ways. For one thing, " ++
                "he hated the summer holidays more than any other time of year. For another, " ++
                "he really wanted to do his homework, but was forced to do it in secret," ++
                "in the dead of the night. And he also happened to be a wizard.",
        ) == .grade_5,
    );

    try testing.expect(
        readability_grade(
            "In my younger and more vulnerable years my father gave me some advice that " ++
                "I've been turning over in my mind ever since.",
        ) == .grade_7,
    );

    try testing.expect(
        readability_grade(
            "Alice was beginning to get very tired of sitting by her sister on the bank, " ++
                "and of having nothing to do: once or twice she had peeped into the book her " ++
                "sister was reading, but it had no pictures or conversations in it, \"and " ++
                "what is the use of a book,\" thought Alice \"without pictures or conversation?\"",
        ) == .grade_8,
    );

    try testing.expect(
        readability_grade(
            "When he was nearly thirteen, my brother Jem got his arm badly broken " ++
                "at the elbow. When it healed, and Jem's fears of never being able to play " ++
                "football were assuaged, he was seldom self-conscious about his injury. " ++
                "His left arm was somewhat shorter than his right; when he stood or walked, " ++
                "the back of his hand was at right angles to his body, his thumb " ++
                "parallel to his thigh. ",
        ) == .grade_8,
    );

    try testing.expect(
        readability_grade(
            "There are more things in Heaven and Earth, Horatio, " ++
                "than are dreamt of in your philosophy. ",
        ) == .grade_9,
    );

    try testing.expect(
        readability_grade(
            "It was a bright cold day in April, and the clocks were striking thirteen. " ++
                "Winston Smith, his chin nuzzled into his breast in an effort to escape " ++
                "the vile wind, slipped quickly through the glass doors of Victory Mansions, " ++
                "though not quickly enough to prevent a swirl of gritty dust from entering " ++
                "along with him. ",
        ) == .grade_10,
    );

    try testing.expect(
        readability_grade(
            "A large class of computational problems involve the determination of " ++
                "properties of graphs, digraphs, integers, arrays of integers, " ++
                "finite families of finite sets, boolean formulas and elements of " ++
                "other countable domains. ",
        ) == .grade_16_plus,
    );
}
