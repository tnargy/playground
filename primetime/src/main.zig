const std = @import("std");
const net: type = std.net;
const posix = std.posix;

pub fn main() !void {
    const addr = net.Address.initIp4(.{ 0, 0, 0, 0 }, 8080);
    const lsnr = try posix.socket(addr.any.family, posix.SOCK.STREAM, posix.IPPROTO.TCP);
    defer posix.close(lsnr);

    try posix.setsockopt(lsnr, posix.SOL.SOCKET, posix.SO.REUSEADDR, &std.mem.toBytes(@as(c_int, 1)));
    try posix.bind(lsnr, &addr.any, addr.getOsSockLen());
    try posix.listen(lsnr, 128);

    var buf: [128]u8 = undefined;
    while (true) {
        var client_address: net.Address = undefined;
        var client_address_len: posix.socklen_t = @sizeOf(net.Address);

        const socket = posix.accept(lsnr, &client_address.any, &client_address_len, 0) catch |err| {
            std.debug.print("error accept: {}\n", .{err});
            continue;
        };
        defer posix.close(socket);

        std.debug.print("{} connected\n", .{client_address});
        
        const read = posix.read(socket, &buf) catch |err| {
            std.debug.print("error reading: {}\n", .{err});
            continue;
        };

        if (read == 0) {
            continue;
        }

        write(socket, buf[0..read]) catch |err| {
            std.debug.print("error writing: {}\n", .{err});
        };
    }
}

fn write(socket: posix.socket_t, msg: []const u8) !void {
    var pos: usize = 0;
    while (pos < msg.len) {
        const written = try posix.write(socket, msg[pos..]);
        if (written == 0) {
            return error.Closed;
        }
        pos += written;
    }
}
