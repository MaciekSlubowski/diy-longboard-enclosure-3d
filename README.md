# Electric Longboard Battery Enclosure

Parametric OpenSCAD script generating a segmented battery enclosure for DIY electric skateboards. The model is divided into interlocking sections using Z-staggered joints to allow printing on standard desktop 3D printers.

## Gallery

<img width="4000" height="3000" alt="20260902_164418" src="https://github.com/user-attachments/assets/68dd4300-88f2-4756-a79b-0acde0fa1e1e" />
*Fully assembled board with the printed enclosure.*

<img width="3000" height="2335" alt="20260802_194715" src="https://github.com/user-attachments/assets/877908eb-af6a-4523-ac37-41317d589025" />

<img width="1022" height="595" alt="Zrzut ekranu 2026-09-07 080557" src="https://github.com/user-attachments/assets/bfb60784-5317-4052-a4b9-1ef877d7ca47" />

*Printed segments connected together on the workbench.*

<img width="3000" height="4000" alt="20260802_194616" src="https://github.com/user-attachments/assets/5094fdd9-b292-4d89-a2a5-3df46966445a" />
*Detail of a single printed enclosure segment showing the Z-joint.*

## Print Bed Requirements

To print the default configuration, your 3D printer must have a minimum build volume of **220 x 220 mm** (compatible with standard machines like the Creality Ender 3). 

The OpenSCAD script calculates the total length of the model (`straight_length` + 2 * `taper_length`) and divides it into 4 equal segments. With the default 740 mm total length, each sliced segment is exactly 185 mm long and up to 220 mm wide.


## Customization Variables

Open the `.scad` file in OpenSCAD to modify the enclosure parameters.

### Main Dimensions
* `straight_length` (Default: 600) - Length of the central straight section (mm). Do not change this value if you need backward compatibility with previously printed segments.
* `right_side_offset` (Default: 40) - Shifts the right wall inward to shorten the final segment without altering the joint coordinates of the remaining parts.
* `total_width` (Default: 220) - Maximum width at the center (mm).
* `end_width` (Default: 160) - Width at the nose and tail sections (mm).
* `outer_height` (Default: 50) - Total depth of the enclosure (mm).

### Walls and Hardware
* `flange_width` (Default: 5) - Width of the top lip contacting the deck.
* `wall_thickness` (Default: 4) - Enclosure shell thickness.
* `screws_per_side` (Default: 6) - Number of mounting holes distributed along one side wall.
* `inner_hole_diameter` (Default: 4) - Diameter for mounting screws (e.g., 4mm for M4).
* `counterbore_diameter` / `counterbore_depth` - Dimensions for recessed screw heads.
* `additional_mounts` - Array for custom internal pillars format: `[X, Y, Rotation]`.

### ESC Heatsink Cutout
* `cutout_length` & `cutout_width` - Dimensions of the heatsink window.
* `cutout_X` & `cutout_Y` - Coordinates of the cutout on the enclosure floor.

### Tolerances
* `print_clearance` (Default: 0.1) - Gap between the interlocking teeth. Default is 0.1 mm. Increase to 0.15 mm or 0.2 mm if the printed joints are too tight.

## Generating STL Files

Change the `part_to_print` variable in the script, render (F6), and export to STL:

* `part_to_print = 0;` - Renders the full uncut enclosure.
* `part_to_print = 1;` - Renders Part 1 (Left end / Nose).
* `part_to_print = 2;` - Renders Part 2 (Middle-left).
* `part_to_print = 3;` - Renders Part 3 (Middle-right).
* `part_to_print = 4;` - Renders Part 4 (Right end / Tail).

This project is open-source and provided strictly for personal, educational, and non-commercial purposes. You are free to explore, modify, and learn from the codebase. **If you wish to use this project for commercial purposes, please contact me.**

