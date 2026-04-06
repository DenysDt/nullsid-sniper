pub const Colour = struct {
    pub const reset = "\x1b[0m";
    pub const bold = "\x1b[1m";


    // colours
    pub const black = "\x1b[30m";
    pub const red = "\x1b[31m";
    pub const green = "\x1b[32m";
    pub const yellow = "\x1b[33m";
    pub const blue = "\x1b[34m";
    pub const magenta = "\x1b[35m";
    pub const cyan = "\x1b[36m";
    pub const white = "\x1b[37m";
    
    // bright colours
    pub const b_red = "\x1b[91m";
    pub const b_green = "\x1b[92m";
    pub const b_yellow = "\x1b[93m";
    pub const b_blue = "\x1b[94m";
    pub const b_magenta = "\x1b[95m";
    pub const b_white = "\x1b[97m";

    // bg colours
    pub const bg_black = "\x1b[40m";
    pub const bg_red = "\x1b[41m";
    pub const bg_green = "\x1b[42m";
    pub const bg_yellow = "\x1b[43m";
    pub const bg_blue = "\x1b[44m";
    pub const bg_magenta = "\x1b[45m";
    pub const bg_white = "\x1b[47m";
};