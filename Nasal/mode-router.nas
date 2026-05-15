# =========================
# MODE ROUTER (MODULE SAFE)
# =========================

var modeNode = props.globals.getNode("/controls/custom/mode", 1);

var getMode = func() {
    if (modeNode == nil) return 0;
    return modeNode.getValue();
};

var setHUD = func(msg) {
    var n = props.globals.getNode("/sim/messages/copilot", 1);
    if (n != nil) n.setValue(msg);
};

var safeSet = func(path, value) {
    var n = props.globals.getNode(path);
    if (n != nil) n.setValue(value);
};

# -------------------------
# MODE SWITCH
# -------------------------
var cycleMode = func() {
    var m = getMode();
    m = m + 1;
    if (m > 3) m = 0;

    if (modeNode != nil) modeNode.setValue(m);

    if (m == 0) setHUD("Mode: CIVILIAN");
    elsif (m == 1) setHUD("Mode: COMBAT");
    elsif (m == 2) setHUD("Mode: HELICOPTER");
    elsif (m == 3) setHUD("Mode: CAMERA");

    print("mode_router: mode =", m);
};

# -------------------------
# PRIMARY ACTION
# -------------------------
var firePrimary = func() {
    var m = getMode();

    if (m == 1) {
        safeSet("/controls/armament/trigger", 1);
    } else {
        safeSet("/controls/gear/brake-left", 1);
        safeSet("/controls/gear/brake-right", 1);
    }
};

# -------------------------
# WEAPON CYCLE
# -------------------------
var weaponCycle = func() {
    var m = getMode();

    if (m == 1) {
        var n = props.globals.getNode("/controls/armament/station-select", 1);
        if (n != nil) n.setValue(n.getValue() + 1);
        setHUD("Weapon cycle");
    }
};

# -------------------------
# MASTER ARM
# -------------------------
var masterArm = func() {
    var m = getMode();

    if (m == 1) {
        var n = props.globals.getNode("/controls/armament/master-arm", 1);
        if (n != nil) n.setValue(!n.getValue());
        setHUD("Master Arm toggled");
    }
};

# -------------------------
# AUTOPILOT
# -------------------------
var toggleAutopilot = func() {
    var m = getMode();

    if (m == 0) {
        var n = props.globals.getNode("/autopilot/locks/altitude", 1);
        if (n != nil) n.setValue(!n.getValue());
    } else {
        setHUD("AP blocked in mode " ~ m);
    }
};

# -------------------------
# MODULE EXPORT
# -------------------------
var mode_router = {
    cycleMode: cycleMode,
    cycle: cycleMode,
    firePrimary: firePrimary,
    weaponCycle: weaponCycle,
    masterArm: masterArm,
    toggleAutopilot: toggleAutopilot
};
# FlightGear Xbox Mode Router (user copy)
# Modes:
# 0 = Civilian
# 1 = Combat
# 2 = Helicopter
# 3 = Camera

var mode = props.globals.getNode("/controls/custom/mode", 1);
if (mode == nil) {
    mode = props.globals.initNode("/controls/custom/mode", 0);
}

var setHUD = func(text) {
    var msg = props.globals.getNode("/sim/messages/copilot", 1);
    if (msg != nil) msg.setValue(text);
}

var cycleMode = func() {
    var m = mode.getValue();

    m = m + 1;
    if (m > 3) {
        m = 0;
    }

    mode.setValue(m);

    # Debug: print mode change for health checks
    print("mode-router: Mode changed to:", m);

    if (m == 0) setHUD("Mode: CIVILIAN");
    elsif (m == 1) setHUD("Mode: COMBAT");
    elsif (m == 2) setHUD("Mode: HELICOPTER");
    elsif (m == 3) setHUD("Mode: CAMERA");
}

# ROUTING FUNCTIONS

var isCombat = func() {
    return mode.getValue() == 1;
}

var isCivil = func() {
    return mode.getValue() == 0;
}

var isHeli = func() {
    return mode.getValue() == 2;
}

var isCamera = func() {
    return mode.getValue() == 3;
}

# EXAMPLE ACTION ROUTER
# These are called from XML bindings via nasal call

var firePrimary = func() {
    if (isCombat()) {
        var n = props.globals.getNode("/controls/armament/trigger", 1);
        if (n != nil) n.setValue(1);
    } else {
        var l = props.globals.getNode("/controls/gear/brake-left", 1);
        var r = props.globals.getNode("/controls/gear/brake-right", 1);
        if (l != nil) l.setValue(1);
        if (r != nil) r.setValue(1);
    }
}

var toggleAutopilot = func() {
    if (isCivil()) {
        var ap = props.globals.getNode("/autopilot/locks/altitude", 1);
        if (ap != nil) ap.setValue(!ap.getValue());
    } elsif (isCombat()) {
        setHUD("Combat AP override");
    }
}

var weaponCycle = func() {
    if (isCombat()) {
        var sel = props.globals.getNode("/controls/armament/station-select", 1);
        if (sel != nil) sel.setValue(sel.getValue() + 1);
        setHUD("Weapon cycled");
    }
}

var masterArm = func() {
    if (isCombat()) {
        var arm = props.globals.getNode("/controls/armament/master-arm", 1);
        if (arm != nil) arm.setValue(!arm.getValue());
        setHUD("Master Arm toggled");
    }
}

var toggleGearOrMasterArm = func() {
    if (isCombat()) {
        masterArm();
    } else {
        var gear = props.globals.getNode("/controls/gear/gear-down", 1);
        if (gear != nil) gear.setValue(!gear.getValue());
        setHUD("Gear toggled");
    }
}

# EXPOSE GLOBALS FOR XML USE
var globals = {
    cycleMode: cycleMode,
    cycle: cycleMode,
    firePrimary: firePrimary,
    toggleAutopilot: toggleAutopilot,
    weaponCycle: weaponCycle,
    masterArm: masterArm,
    toggleGearOrMasterArm: toggleGearOrMasterArm
};
# Public aliases for joystick/XML bindings (ensure callable names exist in globals)
cycle = cycleMode;
next = cycleMode;

# Ensure the loader exposes the same table under the expected name
# so XML bindings can call `mode_router.cycle()` when file loaded via
# `io.load_nasal(routerPath, "mode_router")`.
mode_router = globals;
