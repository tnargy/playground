const std = @import("std");
const RndGen = std.rand.DefaultPrng;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var argsIterator = try std.process.argsWithAllocator(allocator);
    defer argsIterator.deinit();
    
    // Skip executable
    _ = argsIterator.next(); 
    
    if (argsIterator.next()) |arg| {
        if (std.mem.eql(u8, arg, "roll")) {
            // parse dice
            // roll
            const number_of_dice: u32 = 1;
            const size_of_dice: u32 = 6;
            const result = try rollDice(number_of_dice, size_of_dice);
            std.debug.print("{d}D{d} => {d}\n", .{number_of_dice, size_of_dice, result});
        }
    } else {
        std.debug.print("Missing arguments...\n", .{});
    }
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

fn rollDice(number_of_dice: i32, size_of_dice: i32) !i32 {
    if (number_of_dice == 0 or size_of_dice == 0) {
        return 0;
    } else if (size_of_dice == 1) {
        return 1;
    }
    var result: i32 = 0;
    var roll_times = number_of_dice;
    var seed: u64 = undefined;
    try std.posix.getrandom(std.mem.asBytes(&seed));
    var rnd = RndGen.init(seed);

    while (roll_times > 0) {
        const roll = @mod(rnd.random().int(i32), size_of_dice); //D6 would be 0-5
        result += roll + 1;
        roll_times -= 1;
    }
    return result;
}

test "D6 test" {
    const result = try rollDice(1, 6);
    try std.testing.expect(result > 0 and result <= 6);
}

test "2D6 test" {
    const result = try rollDice(2, 6);
    try std.testing.expect(result > 0 and result < 12);
}

test "D0 test" {
    const result = try rollDice(1, 0);
    try std.testing.expectEqual(0, result);
}