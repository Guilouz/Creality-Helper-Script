# High Resolution Bed Mesh

Creality's K1 Max PRTouch v2 implementation loads 36 per-point threshold
entries. Requesting a grid larger than 6x6 can therefore fail at point 37,
even though Klipper's bed mesh implementation supports a larger grid. K1,
K1C, and K1 SE configurations using PRTouch v1 do not use these tables and
must not install this extension.

The optional **High Resolution Bed Mesh** improvement extends those threshold
tables to 100 entries. It does not replace any homing, probing, or motion code,
and it does not change the configured `[bed_mesh]` probe count. Stock `G29`
workflows continue to use their configured grid.

## Installation

On a K1 Max with `pr_version: 2`:

1. Install **Useful Macros** from the Helper Script.
2. Install **High Resolution Bed Mesh** from the Improvements menu.
3. Confirm the extension after Klipper restarts:

   ```gcode
   PRTOUCH_EXTENDED_POINTS_STATUS
   ```

   The reported minimum and maximum table sizes should both be at least 100.

## Usage

Run a full bed calibration with a square grid by passing `POINTS`:

```gcode
BED_LEVELING POINTS=9
```

The supported range is 3 through 10. The macro uses the configured `mesh_min`
and `mesh_max`; Klipper calculates evenly spaced coordinates inside those
bounds. For the K1 Max default 5..295 mm bounds:

| Command | Probes | Spacing |
| --- | ---: | ---: |
| `BED_LEVELING POINTS=6` | 36 | 58.00 mm |
| `BED_LEVELING POINTS=9` | 81 | 36.25 mm |
| `BED_LEVELING POINTS=10` | 100 | 32.22 mm |

The existing temperature parameters are still supported, for example:

```gcode
BED_LEVELING POINTS=9 BED_TEMP=75 HOTEND_TEMP=140 NOZZLE_CLEAR_TEMP=240
```

If KAMP is installed, this command explicitly requests a full bed mesh. KAMP
therefore bypasses object bounds, margins, and fuzzing for this calibration.
Normal adaptive meshes are unchanged.

To persist the result as the default profile, use the normal Klipper workflow
after inspecting the mesh:

```gcode
BED_MESH_PROFILE SAVE=default
SAVE_CONFIG
```

## Safety notes

- Clean the nozzle before probing. Do not probe with plastic stuck below it.
- Inspect the configured `mesh_min` and `mesh_max` before the first run. This
  feature deliberately uses those limits instead of the physical bed edges.
- Start with 9x9. More points take longer and can fit load-cell noise rather
  than real bed shape.
- Requests above 6x6 fail before any generated G-code executes if the PRTouch
  extension is not installed. Requests above 10x10 are rejected.
- The command does not automatically save the mesh.
