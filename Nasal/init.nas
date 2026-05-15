# Init loader to ensure the mode-router Nasal is loaded at startup (user copy)

# Health check: confirm mode property exists and router loaded
print("mode-router init: running loader (user init)");
var modeNode = props.globals.getNode("/controls/custom/mode");
if (modeNode == nil) {
    print("mode-router init: /controls/custom/mode missing, initializing to 0");
    props.globals.initNode("/controls/custom/mode", 0);
} else {
    var v = modeNode.getValue();
    print("mode-router init: /controls/custom/mode present =" ~ v);
}
# =========================
# MODE ROUTER INIT (CLEAN)
# =========================

print("mode-router init: starting");

var modeNode = props.globals.getNode("/controls/custom/mode");

if (modeNode == nil) {
    print("mode-router init: creating /controls/custom/mode = 0");
    modeNode = props.globals.initNode("/controls/custom/mode", 0);
} else {
    print("mode-router init: /controls/custom/mode exists");
}

var v = modeNode.getValue();
print("mode-router init: current mode = " ~ v);

var routerPath = nil;

# Prefer user home, but fall back to fg-root if missing or unavailable
var fg_home = getprop("/sim/fg-home");
if (fg_home != nil) {
    routerPath = fg_home ~ "/Nasal/mode-router.nas";
}

if (routerPath == nil or !io.exists(routerPath)) {
    var fg_root = getprop("/sim/fg-root");
    if (fg_root != nil) {
        routerPath = fg_root ~ "/Nasal/mode-router.nas";
    }
}

if (routerPath != nil and io.exists(routerPath)) {
    print("mode-router init: loading router from " ~ routerPath);
    io.load_nasal(routerPath, "mode_router");
} else {
    print("mode-router init: ERROR no mode-router.nas found in fg-home or fg-root");
}
