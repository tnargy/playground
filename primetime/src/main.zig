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

    var buf: [1024]u8 = undefined;
    while (true) {
        var client_address: net.Address = undefined;
        var client_address_len: posix.socklen_t = @sizeOf(net.Address);

        const socket = posix.accept(lsnr, &client_address.any, &client_address_len, 0) catch |err| {
            std.debug.print("error accept: {}\n", .{err});
            continue;
        };
        defer posix.close(socket);

        std.debug.print("{} connected\n", .{client_address});

        const timeout = posix.timeval{ .tv_sec = 5, .tv_usec = 0 };
        try posix.setsockopt(socket, posix.SOL.SOCKET, posix.SO.RCVTIMEO, &std.mem.toBytes(timeout));
        try posix.setsockopt(socket, posix.SOL.SOCKET, posix.SO.SNDTIMEO, &std.mem.toBytes(timeout));

        const stream = std.net.Stream{ .handle = socket };

        const read = try stream.read(&buf);
        if (read == 0) {
            continue;
        }
        try stream.writeAll(buf[0..read]);
    }
}
