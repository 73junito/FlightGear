# FlightGear Mode Router

Verified working FlightGear controller mode-router setup.

## Files

- `Nasal/init.nas` — loads the mode router at startup.
- `Nasal/mode-router.nas` — exports `mode_router.cycle()`.
- `Input/Joysticks/Microsoft/xbox-360-controller.xml` — maps Select/Back button 6 to `mode_router.cycle();`.

## Verified behavior

Select/Back cycles:

CIVILIAN → COMBAT → HELICOPTER → CAMERA → CIVILIAN

Fresh `fgfs.log` confirmed clean `mode-router` output with no temporary diagnostics.
