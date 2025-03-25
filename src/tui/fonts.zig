const Plane = @import("renderer").Plane;
const Style = @import("theme").Style;

pub fn print_string_large(n: *Plane, s: []const u8, style: Style) !void {
    for (s) |c|
        print_char_large(n, c, style) catch break;
}

pub fn print_char_large(n: *Plane, char: u8, style: Style) !void {
    const bitmap = font8x8[char];
    for (0..8) |y| {
        for (0..8) |x| {
            const set = bitmap[y] & @as(usize, 1) << @intCast(x);
            if (set != 0) {
                try write_cell(n, "█", style);
            } else {
                n.cursor_move_rel(0, 1) catch {};
            }
        }
        n.cursor_move_rel(1, -8) catch {};
    }
    n.cursor_move_rel(-8, 8) catch {};
}

pub fn print_string_medium(n: *Plane, s: []const u8, style: Style) !void {
    for (s) |c|
        print_char_medium(n, c, style) catch break;
}

const QUADBLOCKS = [_][:0]const u8{ " ", "▘", "▝", "▀", "▖", "▌", "▞", "▛", "▗", "▚", "▐", "▜", "▄", "▙", "▟", "█" };

pub fn print_char_medium(n: *Plane, char: u8, style: Style) !void {
    const bitmap = font8x8[char];
    for (0..4) |y| {
        for (0..4) |x| {
            const yt = 2 * y;
            const yb = 2 * y + 1;
            const xl = 2 * x;
            const xr = 2 * x + 1;
            const settl: u4 = if (bitmap[yt] & @as(usize, 1) << @intCast(xl) != 0) 1 else 0;
            const settr: u4 = if (bitmap[yt] & @as(usize, 1) << @intCast(xr) != 0) 2 else 0;
            const setbl: u4 = if (bitmap[yb] & @as(usize, 1) << @intCast(xl) != 0) 4 else 0;
            const setbr: u4 = if (bitmap[yb] & @as(usize, 1) << @intCast(xr) != 0) 8 else 0;
            const quadidx: u4 = setbr | setbl | settr | settl;
            const c = QUADBLOCKS[quadidx];
            if (quadidx != 0) {
                try write_cell(n, c, style);
            } else {
                n.cursor_move_rel(0, 1) catch {};
            }
        }
        n.cursor_move_rel(1, -4) catch {};
    }
    n.cursor_move_rel(-4, 4) catch {};
}

fn write_cell(n: *Plane, egc: [:0]const u8, style: Style) !void {
    var cell = n.cell_init();
    _ = n.at_cursor_cell(&cell) catch return;
    _ = n.cell_load(&cell, egc) catch {};
    cell.set_style_fg(style);
    _ = n.putc(&cell) catch {};
}

pub const font8x8: [128][8]u8 = [128][8]u8{
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 24, 60, 60, 24, 24, 0, 24, 0 },
    [8]u8{ 54, 54, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 54, 54, 127, 54, 127, 54, 54, 0 },
    [8]u8{ 12, 62, 3, 30, 48, 31, 12, 0 },
    [8]u8{ 0, 99, 51, 24, 12, 102, 99, 0 },
    [8]u8{ 28, 54, 28, 110, 59, 51, 110, 0 },
    [8]u8{ 6, 6, 3, 0, 0, 0, 0, 0 },
    [8]u8{ 24, 12, 6, 6, 6, 12, 24, 0 },
    [8]u8{ 6, 12, 24, 24, 24, 12, 6, 0 },
    [8]u8{ 0, 102, 60, 255, 60, 102, 0, 0 },
    [8]u8{ 0, 12, 12, 63, 12, 12, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 12, 12, 6 },
    [8]u8{ 0, 0, 0, 63, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 12, 12, 0 },
    [8]u8{ 96, 48, 24, 12, 6, 3, 1, 0 },
    [8]u8{ 62, 99, 115, 123, 111, 103, 62, 0 },
    [8]u8{ 12, 14, 12, 12, 12, 12, 63, 0 },
    [8]u8{ 30, 51, 48, 28, 6, 51, 63, 0 },
    [8]u8{ 30, 51, 48, 28, 48, 51, 30, 0 },
    [8]u8{ 56, 60, 54, 51, 127, 48, 120, 0 },
    [8]u8{ 63, 3, 31, 48, 48, 51, 30, 0 },
    [8]u8{ 28, 6, 3, 31, 51, 51, 30, 0 },
    [8]u8{ 63, 51, 48, 24, 12, 12, 12, 0 },
    [8]u8{ 30, 51, 51, 30, 51, 51, 30, 0 },
    [8]u8{ 30, 51, 51, 62, 48, 24, 14, 0 },
    [8]u8{ 0, 12, 12, 0, 0, 12, 12, 0 },
    [8]u8{ 0, 12, 12, 0, 0, 12, 12, 6 },
    [8]u8{ 24, 12, 6, 3, 6, 12, 24, 0 },
    [8]u8{ 0, 0, 63, 0, 0, 63, 0, 0 },
    [8]u8{ 6, 12, 24, 48, 24, 12, 6, 0 },
    [8]u8{ 30, 51, 48, 24, 12, 0, 12, 0 },
    [8]u8{ 62, 99, 123, 123, 123, 3, 30, 0 },
    [8]u8{ 12, 30, 51, 51, 63, 51, 51, 0 },
    [8]u8{ 63, 102, 102, 62, 102, 102, 63, 0 },
    [8]u8{ 60, 102, 3, 3, 3, 102, 60, 0 },
    [8]u8{ 31, 54, 102, 102, 102, 54, 31, 0 },
    [8]u8{ 127, 70, 22, 30, 22, 70, 127, 0 },
    [8]u8{ 127, 70, 22, 30, 22, 6, 15, 0 },
    [8]u8{ 60, 102, 3, 3, 115, 102, 124, 0 },
    [8]u8{ 51, 51, 51, 63, 51, 51, 51, 0 },
    [8]u8{ 30, 12, 12, 12, 12, 12, 30, 0 },
    [8]u8{ 120, 48, 48, 48, 51, 51, 30, 0 },
    [8]u8{ 103, 102, 54, 30, 54, 102, 103, 0 },
    [8]u8{ 15, 6, 6, 6, 70, 102, 127, 0 },
    [8]u8{ 99, 119, 127, 127, 107, 99, 99, 0 },
    [8]u8{ 99, 103, 111, 123, 115, 99, 99, 0 },
    [8]u8{ 28, 54, 99, 99, 99, 54, 28, 0 },
    [8]u8{ 63, 102, 102, 62, 6, 6, 15, 0 },
    [8]u8{ 30, 51, 51, 51, 59, 30, 56, 0 },
    [8]u8{ 63, 102, 102, 62, 54, 102, 103, 0 },
    [8]u8{ 30, 51, 7, 14, 56, 51, 30, 0 },
    [8]u8{ 63, 45, 12, 12, 12, 12, 30, 0 },
    [8]u8{ 51, 51, 51, 51, 51, 51, 63, 0 },
    [8]u8{ 51, 51, 51, 51, 51, 30, 12, 0 },
    [8]u8{ 99, 99, 99, 107, 127, 119, 99, 0 },
    [8]u8{ 99, 99, 54, 28, 28, 54, 99, 0 },
    [8]u8{ 51, 51, 51, 30, 12, 12, 30, 0 },
    [8]u8{ 127, 99, 49, 24, 76, 102, 127, 0 },
    [8]u8{ 30, 6, 6, 6, 6, 6, 30, 0 },
    [8]u8{ 3, 6, 12, 24, 48, 96, 64, 0 },
    [8]u8{ 30, 24, 24, 24, 24, 24, 30, 0 },
    [8]u8{ 8, 28, 54, 99, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 255 },
    [8]u8{ 12, 12, 24, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 30, 48, 62, 51, 110, 0 },
    [8]u8{ 7, 6, 6, 62, 102, 102, 59, 0 },
    [8]u8{ 0, 0, 30, 51, 3, 51, 30, 0 },
    [8]u8{ 56, 48, 48, 62, 51, 51, 110, 0 },
    [8]u8{ 0, 0, 30, 51, 63, 3, 30, 0 },
    [8]u8{ 28, 54, 6, 15, 6, 6, 15, 0 },
    [8]u8{ 0, 0, 110, 51, 51, 62, 48, 31 },
    [8]u8{ 7, 6, 54, 110, 102, 102, 103, 0 },
    [8]u8{ 12, 0, 14, 12, 12, 12, 30, 0 },
    [8]u8{ 48, 0, 48, 48, 48, 51, 51, 30 },
    [8]u8{ 7, 6, 102, 54, 30, 54, 103, 0 },
    [8]u8{ 14, 12, 12, 12, 12, 12, 30, 0 },
    [8]u8{ 0, 0, 51, 127, 127, 107, 99, 0 },
    [8]u8{ 0, 0, 31, 51, 51, 51, 51, 0 },
    [8]u8{ 0, 0, 30, 51, 51, 51, 30, 0 },
    [8]u8{ 0, 0, 59, 102, 102, 62, 6, 15 },
    [8]u8{ 0, 0, 110, 51, 51, 62, 48, 120 },
    [8]u8{ 0, 0, 59, 110, 102, 6, 15, 0 },
    [8]u8{ 0, 0, 62, 3, 30, 48, 31, 0 },
    [8]u8{ 8, 12, 62, 12, 12, 44, 24, 0 },
    [8]u8{ 0, 0, 51, 51, 51, 51, 110, 0 },
    [8]u8{ 0, 0, 51, 51, 51, 30, 12, 0 },
    [8]u8{ 0, 0, 99, 107, 127, 127, 54, 0 },
    [8]u8{ 0, 0, 99, 54, 28, 54, 99, 0 },
    [8]u8{ 0, 0, 51, 51, 51, 62, 48, 31 },
    [8]u8{ 0, 0, 63, 25, 12, 38, 63, 0 },
    [8]u8{ 56, 12, 12, 7, 12, 12, 56, 0 },
    [8]u8{ 24, 24, 24, 0, 24, 24, 24, 0 },
    [8]u8{ 7, 12, 12, 56, 12, 12, 7, 0 },
    [8]u8{ 110, 59, 0, 0, 0, 0, 0, 0 },
    [8]u8{ 0, 0, 0, 0, 0, 0, 0, 0 },
};

pub const font_test_text: []const u8 =
    \\
    \\notcurses (3.0.9) glyph rendering test suite:
    \\
    \\  ▘▝▀▖▌▞▛▗▚▐▜▄▙▟█⎧ 🬀🬁🬂🬃🬄🬅🬆🬇🬈🬊🬋🬌🬍🬎🬏🬐🬑🬒🬓▌🬔🬕🬖🬗🬘🬙🬚🬛🬜🬝⎫♠♥🯰🯱🯲🯳🯴🯵🯶🯷🯸🯹⅗⅘⅙⅚⅛⎧▕▏⎫┌╥─╥─╥┐🭩⎛⎞
    \\ ╲╿╱ ◨◧ ◪◩ ◖◗ ⫷⫸ ⎩🬟🬠🬡🬢🬣🬤🬥🬦🬧▐🬨🬩🬪🬫🬬🬭🬮🬯🬰🬱🬲🬳🬴🬵🬶🬷🬸🬹🬺🬻█⎭♦♣¼½¾⅐⅑⅒⅓⅔⅕⅖⅜⅝⅞⅟↉⎪🮇▎⎪├╜╓╫╖╙┤🭫⎜⎟
    \\ ╾╳╼ ◲◱ ◶◵ 🮣🮠 🮤🮥◜◝ ◿◺ 🮞🮟 ◢◣ ┌┐─ ┏┓━ ╭╮─ ╔╗═ 🭽🭾▁♟♜♞⩘▵△▹▷▿▽◃◁⭡⭣⭠⭢⭧⭩⭦⭨⎪🮈▍⎪├─╨╫╨─┤┇⎜⎟
    \\ ╱╽╲ ◳◰ ◷◴ 🮡🮢 🮦🮧◟◞ ◹◸ 🮝🮜 ◥◤ └┘│ ┗┛┃ ╰╯│ ╚╝║ 🭼🭿🭵♝♛♚⩗▴⏶⯅▲▸⏵⯈▶▾⏷⯆▼◂⏴⯇◀⎪▐▌⎪╞═╤╬╤═╡┋⎜⎟
    \\ ⎡⠀⠁⠈⠉⠂⠃⠊⠋⠐⠑⠘⠙⠒⠓⠚⠛⠄⠅⠌⠍⠆⠇⠎⠏⠔⠕⠜⠝⠖⠗⠞⠟⠠⠡⠨⠩⠢⠣⠪⠫⠰⠱⠸⠹⠲⠳⠺⠻⠤⠥⠬⠭⠦⠧⠮⠯⠴⠵⠼⠽⠶⠷⠾⠿⎤⎨🮉▋⎬╞╕╘╬╛╒╡┊⎜⎟
    \\ ⎢⡀⡁⡈⡉⡂⡃⡊⡋⡐⡑⡘⡙⡒⡓⡚⡛⡄⡅⡌⡍⡆⡇⡎⡏⡔⡕⡜⡝⡖⡗⡞⡟⡠⡡⡨⡩⡢⡣⡪⡫⡰⡱⡸⡹⡲⡳⡺⡻⡤⡥⡬⡭⡦⡧⡮⡯⡴⡵⡼⡽⡶⡷⡾⡿⎥⎪🮊▊⎪└┴─╨─┴┘╏⎝⎠
    \\ ⎢⢀⢁⢈⢉⢂⢃⢊⢋⢐⢑⢘⢙⢒⢓⢚⢛⢄⢅⢌⢍⢆⢇⢎⢏⢔⢕⢜⢝⢖⢗⢞⢟⢠⢡⢨⢩⢢⢣⢪⢫⢰⢱⢸⢹⢲⢳⢺⢻⢤⢥⢬⢭⢦⢧⢮⢯⢴⢵⢼⢽⢶⢷⢾⢿⎥⎪🮋▉⎪╭──╮⟬⟭╔╗≶≷
    \\ ⎣⣀⣁⣈⣉⣂⣃⣊⣋⣐⣑⣘⣙⣒⣓⣚⣛⣄⣅⣌⣍⣆⣇⣎⣏⣔⣕⣜⣝⣖⣗⣞⣟⣠⣡⣨⣩⣢⣣⣪⣫⣰⣱⣸⣹⣲⣳⣺⣻⣤⣥⣬⣭⣦⣧⣮⣯⣴⣵⣼⣽⣶⣷⣾⣿⎦⎪██⎪│╭╮│╔═╝║⊆⊇
    \\  ▔🭶🭷🭸🭹🭺🭻▁ 🭁🭌 🭂🭍 🭃🭎 🭄🭏 🭅🭐 🭆🭑 🭇🬼 🭈🬽 🭉🬾 🭊🬿 🭋🭀 ₀₁₂₃₄₅₆₇₈₉ ⎛ ▁▂▃▄▅▆▇█🭫⎞⎪🭨🭪⎪╰╯││║╔═╝⊴⊵
    \\  ▏🭰🭱🭲🭳🭴🭵▕ 🭒🭝 🭓🭞 🭔🭟 🭕🭠 🭖🭡 🭧🭜 🭢🭗 🭣🭘 🭤🭙 🭥🭚 🭦🭛 ⁰¹²³⁴⁵⁶⁷⁸⁹ ⎝ ▔🮂🮃▀🮄🮅🮆█🭩⎠⎩🭪🭨⎭⧒⧑╰╯╚╝❨❩⟃⟄
    \\ 👾🏴🤘🚬🌍🌎🌏🥆💣🗡🔫⚗️⚛️☢️☣️🌿🎱🏧💉💊🕴️📡🤻🦑🇦🇶👩‍🔬🪤🚱✊🏿🔬🧬🏴‍☠️🤽🏼‍♀️
    \\
    \\
    \\Unicode mode 2027 tests:
    \\
    \\xxxxxxxxxx
    \\xxxx🧑‍🌾xxxx
    \\xxxxxxxxxx
    \\
    \\xxxxxxxxxxxxxxxxxxxxxxxx
    \\xx🧑‍🌾🧑‍🌾🧑‍🌾🧑‍🌾🧑‍🌾🧑‍🌾🧑‍🌾🧑‍🌾🧑‍🌾🧑‍🌾xx
    \\xx🧑‍🌾🧑‍🌾🧑‍🌾🧑‍🌾🧑‍🌾🧑‍🌾🧑‍🌾🧑‍🌾🧑‍🌾🧑‍🌾xx
    \\xxxxxxxxxxxxxxxxxxxxxxxx
    \\
    \\🙂‍↔
    \\
    \\
    \\ recommended fonts for terminals with no nerdfont fallback support (e.g. flow-gui):
    \\
    \\ "IosevkaTerm Nerd Font" => https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/IosevkaTerm.zip
    \\ "Cascadia Code NF" => https://github.com/microsoft/cascadia-code/releases/download/v2407.24/CascadiaCode-2407.24.zip
    \\
;

pub const DigitStyle = @import("config").DigitStyle;

pub fn get_digit(n: anytype, style_: DigitStyle) []const u8 {
    return switch (style_) {
        .ascii => digits_ascii[n],
        .digital => digits_digtl[n],
        .subscript => digits_subsc[n],
        .superscript => digits_super[n],
    };
}

pub fn get_digit_ascii(char: []const u8, style_: DigitStyle) []const u8 {
    if (char.len == 0) return " ";
    if (char[0] > '9' or char[0] < '0') return char;
    return get_digit(char[0] - '0', style_);
}

const digits_ascii: [10][]const u8 = .{ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" };
const digits_digtl: [10][]const u8 = .{ "🯰", "🯱", "🯲", "🯳", "🯴", "🯵", "🯶", "🯷", "🯸", "🯹" };
const digits_subsc: [10][]const u8 = .{ "₀", "₁", "₂", "₃", "₄", "₅", "₆", "₇", "₈", "₉" };
const digits_super: [10][]const u8 = .{ "⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹" };
