const std = @import("std");

const print = std.debug.print;

//createStr template: https://profiles.dnull.xyz/update?handle=
//                    handle
//                    &image_ref=60bd3bc7-c9cb-433e-90a9-6e4e44c4a846

fn changeID(url: []const u8, bearer: []const u8, client: *std.http.Client) std.http.Status {
    const uri = std.Uri.parse(url) catch {
        return .bad_request;
    };

    const fopt: std.http.Client.FetchOptions = .{ .method = .POST, .location = .{ .uri = uri }, .headers = .{ .authorization = .{ .override = bearer } }, .payload = "" };

    const res = client.fetch(fopt) catch {
        return .bad_request;
    };
    return res.status;
}

fn soCalledWhileLoop(url: []const u8, handle: []const u8, bearer: []const u8, io: *const std.Io, alloc: std.mem.Allocator) void {
    var client = std.http.Client{ .allocator = alloc, .io = io.* };
    defer client.deinit();
    var state: u3 = 1;
    print("Sniping... ({s})", .{handle});
    sniper: while (true) {
        const res = changeID(url, bearer, &client);
        switch (res) {
            .ok => {
                print("\nSniped ({s})!\n", .{handle});
                break :sniper;
            },
            .teapot => {
                switch (state) {
                    1 => {print("\rSniping.   ({s})", .{handle}); state += 1;},
                    2 => {print("\rSniping..  ({s})", .{handle}); state += 1;},
                    3 => {print("\rSniping... ({s})", .{handle}); state += 1;},
                    4 => {print("\rSniping....({s})", .{handle}); state = 1;}, else => {}
                }
            },
            else => {
                print("API returned something... completely weird?? (status: {d})\n", .{res});
                break :sniper;
            },
        }
        io.sleep(std.Io.Duration.fromMilliseconds(100), .awake) catch {
            print("Error within io.sleep", .{});
            break :sniper;
        };
    }
}

pub fn main(init: std.process.Init) !void {
    const alloc = init.gpa;
    const io = init.io;

    const handle = ""; //your nullsid here (the one u r going to snipe)
    const bearerstr = ""; //your token here

    const strlist = &[_][]const u8{
        "https://profiles.dnull.xyz/update?handle=",
        handle,
        "&image_ref=60bd3bc7-c9cb-433e-90a9-6e4e44c4a846",
    };

    const bearerlist = &[_][]const u8{
        "Bearer ",
        bearerstr,
    };

    const url = try std.mem.concat(alloc, u8, strlist);
    const bearer = try std.mem.concat(alloc, u8, bearerlist);
    defer alloc.free(url);
    defer alloc.free(bearer);

    

    {
        print("Encountering issues? Text @denysdt on tg or dc, maybe I'll look into it idk\n\n", .{});
        const thr = try std.Thread.spawn(.{}, soCalledWhileLoop, .{ url, handle, bearer, &io, alloc });
        defer thr.join();

        print("Started the loop...\n", .{});
    }

    //std.debug.print("status={d}\n", .{res});
}
