const std = @import("std");
const bmp = @import("bmp.zig");
const assert = std.debug.assert;
const print = std.debug.print;
const Image = @This();
const Allocator = std.mem.Allocator;

pub const ImageErrors = error{
    InvalidFileName,
    FileNotFound,
    InvalidFormat,
    FileCannotBeOpened,
};

height: i32,
width: i32,
bmp_file_header: bmp.BitMapFileHeader,
bmp_info_header: bmp.BitMapInfoHeader,
pixels: [][]bmp.RGBTriple,
allocator: Allocator,
padding: i32,

pub fn init(allocator: Allocator, width: i32, height: i32) !Image {
    const pixels = try allocator.alloc([]bmp.RGBTriple, @as(usize, @intCast(height)));
    for (pixels) |*row| {
        row.* = try allocator.alloc(bmp.RGBTriple, @as(usize, @intCast(width)));
    }

    return .{
        .height = height,
        .width = width,
        .bmp_file_header = undefined,
        .bmp_info_header = undefined,
        .pixels = pixels,
        .allocator = allocator,
        .padding = undefined,
    };
}

pub fn deinit(self: *Image) void {
    for (self.pixels) |row| {
        self.allocator.free(row);
    }
    self.allocator.free(self.pixels);
}

/// Caller has to call deinit() to free up memory
pub fn load_input_image(allocator: Allocator, file_path: []const u8) !Image {
    assert(file_path.len > 0);
    if(!std.mem.endsWith(u8, file_path, ".bmp")) {
        return ImageErrors.InvalidFileName;
    }

    const file = std.fs.cwd().openFile(file_path, .{}) catch {
        return ImageErrors.FileNotFound;
    };
    defer file.close();

    const file_header = bmp.BitMapFileHeader{
        .bf_type = try file.reader().readInt(bmp.word, .little),
        .bf_size = try file.reader().readInt(bmp.dword, .little),
        .bf_reserved_1 = try file.reader().readInt(bmp.word, .little),
        .bf_reserved_2 = try file.reader().readInt(bmp.word, .little),
        .bf_off_bits = try file.reader().readInt(bmp.dword, .little),
    };
    const info_header = bmp.BitMapInfoHeader{
        .bit_size = try file.reader().readInt(bmp.dword, .little),
        .bit_width = try file.reader().readInt(bmp.long, .little),
        .bit_height = try file.reader().readInt(bmp.long, .little),
        .bit_planes = try file.reader().readInt(bmp.word, .little),
        .bit_bit_count = try file.reader().readInt(bmp.word, .little),
        .bit_compression = try file.reader().readInt(bmp.dword, .little),
        .bit_size_image = try file.reader().readInt(bmp.dword, .little),
        .bit_x_pels_per_meter = try file.reader().readInt(bmp.long, .little),
        .bit_y_pels_per_meter = try file.reader().readInt(bmp.long, .little),
        .bit_clr_used = try file.reader().readInt(bmp.dword, .little),
        .bit_clr_important = try file.reader().readInt(bmp.dword, .little),
    };

    // Ensure input_file.bmp is (likely) a 24-bit uncompresssed BMP 4.0
    if (file_header.bf_type != 0x4d42 or
        file_header.bf_off_bits != 54 or
        info_header.bit_size != 40 or
        info_header.bit_bit_count != 24 or
        info_header.bit_compression != 0)
    {
        return ImageErrors.InvalidFormat;
    }

    const height: i32 = @intCast(@abs(info_header.bit_height));
    const width: i32 = info_header.bit_width;
    assert(height > 0 and width > 0);

    var image = try Image.init(allocator, width, height);
    image.bmp_file_header = file_header;
    image.bmp_info_header = info_header;

    image.padding = @mod(4 - @mod(image.width * @sizeOf(bmp.RGBTriple), 4), 4);
    assert(image.padding >= 0);
    assert(image.padding <= 3);
    for (image.pixels) |row| {
        _ = try file.readAll(std.mem.sliceAsBytes(row));
        try file.seekBy(image.padding);
    }

    return image;
}

pub fn save_output_image(self: *const Image, file_path: []const u8) !void {
    assert(file_path.len > 0);
    if (!std.mem.endsWith(u8, file_path, ".bmp") or file_path.len < 5) {
        return ImageErrors.InvalidFileName;
    }
    assert(self.width > 0 and self.height > 0);
    assert(self.padding >= 0 and self.padding <= 3);

    var output_dir = try std.fs.cwd().openDir("output", .{});
    defer output_dir.close();

    const file = output_dir.createFile(file_path, .{}) catch {
        return ImageErrors.FileCannotBeOpened;
    };
    defer file.close();

    try file.writer().writeInt(bmp.word, self.bmp_file_header.bf_type, .little);
    try file.writer().writeInt(bmp.dword, self.bmp_file_header.bf_size, .little);
    try file.writer().writeInt(bmp.word, self.bmp_file_header.bf_reserved_1, .little);
    try file.writer().writeInt(bmp.word, self.bmp_file_header.bf_reserved_2, .little);
    try file.writer().writeInt(bmp.dword, self.bmp_file_header.bf_off_bits, .little);

    try file.writer().writeInt(bmp.dword, self.bmp_info_header.bit_size, .little); 
    try file.writer().writeInt(bmp.long, self.bmp_info_header.bit_width, .little); 
    try file.writer().writeInt(bmp.long, self.bmp_info_header.bit_height, .little); 
    try file.writer().writeInt(bmp.word, self.bmp_info_header.bit_planes, .little); 
    try file.writer().writeInt(bmp.word, self.bmp_info_header.bit_bit_count, .little); 
    try file.writer().writeInt(bmp.dword, self.bmp_info_header.bit_compression, .little); 
    try file.writer().writeInt(bmp.dword, self.bmp_info_header.bit_size_image, .little); 
    try file.writer().writeInt(bmp.long, self.bmp_info_header.bit_x_pels_per_meter, .little); 
    try file.writer().writeInt(bmp.long, self.bmp_info_header.bit_y_pels_per_meter, .little); 
    try file.writer().writeInt(bmp.dword, self.bmp_info_header.bit_clr_used, .little); 
    try file.writer().writeInt(bmp.dword, self.bmp_info_header.bit_clr_important, .little); 

    const padding_bytes = [_]u8{0} ** 4;
    for (self.pixels) |row| {
        try file.writeAll(std.mem.sliceAsBytes(row));
        if (self.padding > 0) {
            assert(self.padding <= padding_bytes.len);
            try file.writeAll(padding_bytes[0..@as(usize, @intCast(self.padding))]);
        }
    }
}
