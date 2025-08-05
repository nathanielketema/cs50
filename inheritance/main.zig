const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const testing = std.testing;

const indent_length = 4;
const generations = 3;

// Global pseudo random number generator
var global_prng: std.Random.DefaultPrng = undefined;
var prng_initialized = false;

// Zig doesn't let us call a runtime function (nanoTimestamp()) at a global scope
// So this function will be called when needed at runtime
fn init_prng() void {
    if (!prng_initialized) {
        const seed: u64 = @intCast(std.time.nanoTimestamp());
        global_prng = std.Random.DefaultPrng.init(seed);
        prng_initialized = true;
    }
}

const Allele = enum(u8) {
    A = 'A',
    B = 'B',
    O = 'O',

    fn random_allele() Allele {
        init_prng();
        return global_prng.random().enumValue(Allele);
    }

    fn random_allele_based_on_parents(
        parent_0: [2]Allele,
        parent_1: [2]Allele,
    ) [2]Allele {
        init_prng();

        const from_parent_0: Allele = if (global_prng.random().boolean()) parent_0[0] else parent_0[1];
        const from_parent_1: Allele = if (global_prng.random().boolean()) parent_1[0] else parent_1[1];

        return .{ from_parent_0, from_parent_1 };
    }
};

const Person = struct {
    parents: ?*[2]Person,
    alleles: ?[2]Allele,
    allocator: std.mem.Allocator,

    fn free(self: *Person) void {
        // Base case
        if (self.parents == null) {
            return;
        }

        self.parents.?[0].free();
        self.parents.?[1].free();

        self.allocator.destroy(self.parents.?);
    }

    fn create_family(allocator: std.mem.Allocator, generation: u8) !Person {
        assert(generation > 0 and generation <= 10);
        var person: Person = .{
            .parents = null,
            .alleles = null,
            .allocator = allocator,
        };

        if (generation > 1) {
            const parent = try allocator.create([2]Person);

            parent[0] = try Person.create_family(allocator, generation - 1);
            parent[1] = try Person.create_family(allocator, generation - 1);
            const alleles = Allele.random_allele_based_on_parents(
                parent[0].alleles.?,
                parent[1].alleles.?,
            );

            person = .{
                .parents = parent,
                .alleles = alleles,
                .allocator = allocator,
            };
        } else {
            person = .{
                .parents = null,
                .alleles = .{ Allele.random_allele(), Allele.random_allele() },
                .allocator = allocator,
            };
        }

        return person;
    }

    fn print_family(self: *Person, generation: u8) void {
        assert(generation <= 10);
        for (0..generation * indent_length) |_| {
            print(" ", .{});
        }

        if (generation == 0) {
            print(
                "Child (Generation {d}): blood type {c}{c}\n",
                .{
                    generation,
                    @intFromEnum(self.*.alleles.?[0]),
                    @intFromEnum(self.*.alleles.?[1]),
                },
            );
        } else if (generation == 1) {
            print(
                "Parent (Generation {d}): blood type {c}{c}\n",
                .{
                    generation,
                    @intFromEnum(self.*.alleles.?[0]),
                    @intFromEnum(self.*.alleles.?[1]),
                },
            );
        } else {
            for (0..generation - 2) |_| {
                print("Great-", .{});
            }
            print(
                "Grandparent (Generation {d}): blood type {c}{c}\n",
                .{
                    generation,
                    @intFromEnum(self.*.alleles.?[0]),
                    @intFromEnum(self.*.alleles.?[1]),
                },
            );
        }

        if (self.parents) |parents| {
            parents[0].print_family(generation + 1);
            parents[1].print_family(generation + 1);
        }
    }
};

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    var person = try Person.create_family(allocator, generations);
    defer person.free();
    person.print_family(0);
}

test "check random_allele" {
    const foo = Allele.random_allele();
    try testing.expectEqual(Allele, @TypeOf(foo));
    try testing.expect(foo == .A or foo == .B or foo == .O);
}

test "check memory leaks" {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    for (0..10) |_| {
        var person = try Person.create_family(allocator, 3);
        person.free();
    }
}
