// ============================================================================
// BATTERY ENCLOSURE - 3D INTERLOCKING SYSTEM
// Features: Internal Mesh Welding, Z-Staggering Joints, Render Caching
// ============================================================================

// Global resolution for curved surfaces (higher = smoother, but slower rendering)
$fn = 60; 

// --- 1. MAIN DIMENSIONS & SHAPE PARAMETERS ---
// NOTE: Do not change 'straight_length' to maintain full compatibility with printed parts 1, 2, and 3!
straight_length = 600;      // Length of the central straight section [mm]
taper_length = 70;          // Length of the angled/tapered sections at both ends [mm]
total_width = 220;          // Maximum width of the enclosure at the center [mm]
end_width = 160;            // Width of the enclosure at the very ends (nose/tail) [mm]
outer_height = 50;          // Total outer height/depth of the enclosure [mm]

// 🔥 NEW PARAMETER: Shifts the right wall inward without breaking the rest of the model.
// Useful if you need to slightly shorten the total length on one side for a specific deck.
right_side_offset = 40; 

// --- WALLS & FLANGES ---
flange_width = 5;           // Width of the top lip/flange used to seal against the deck [mm]
flange_thickness = 5;       // Thickness (Z-height) of the top lip [mm]
wall_thickness = 4;         // General thickness of the enclosure walls and bottom [mm]

// --- RADII & FILLETS ---
outer_radius = 35;          // Corner radius for the central straight section [mm]
end_radius = 60;            // Corner radius for the nose/tail tips [mm]
bottom_fillet_radius = 15;  // Rounding radius connecting the side walls to the bottom floor [mm]

// --- HEAT SINK CUTOUT PARAMETERS (e.g. for ESC cooling) ---
cutout_length = 134;        // Length of the rectangular cutout for the heat sink [mm]
cutout_width = 110;         // Width of the rectangular cutout [mm]
cutout_X = -260;            // X-axis position of the cutout (negative values move it towards the left)
cutout_Y = 0;               // Y-axis position (0 = centered)

// --- 2. INTERNAL SCREW MOUNTS & STANDOFFS ---

// Note: 'screw_positions_X' is a legacy reference array. 
// The actual placement of side screws is dynamically calculated via the 'screws_per_side' loop below.
screw_positions_X = [-200, -100, 0, 100, 200]; 

// Additional custom standoffs (e.g., for mounting the BMS, ESC, or battery straps)
// Format: [X_position, Y_position, Rotation_angle, Z_unused]
additional_mounts = [  
    // Rear pillars are shifted left by 'right_side_offset' to stay inside the shortened wall
    [335 - right_side_offset, 70, 90, 100],    
    [335 - right_side_offset, -70, -90, -100]  
];

// --- HARDWARE SPECS (Screws / Threaded Inserts) ---
mount_radius = 5;           // Outer radius of the plastic pillar holding the screw [mm] (Diameter = 10mm)
inner_hole_diameter = 4;    // Diameter of the through-hole (e.g., 4mm for M4 screws or heat-set inserts)
counterbore_diameter = 8;   // Diameter of the recessed hole for the screw head [mm]
counterbore_depth = 8;      // Depth of the recess for the screw head [mm]

// --- SIDE WALL MOUNTING HOLES DISTRIBUTION ---
screws_per_side = 6;        // Number of mounting holes distributed evenly along ONE side wall (total = 12)
x_start_screw = -straight_length / 2;     // X-coordinate of the first screw (start of the straight section)
x_end_screw = straight_length / 2 - 50;   // X-coordinate of the last screw (end of the straight section minus offset)
screw_step = (x_end_screw - x_start_screw) / (screws_per_side - 1); // Auto-calculated distance between screws

// --- 3. PRINT & SLICE SETTINGS ---
// Select which part of the enclosure to render for exporting to STL.
// 0 = Full uncut model (for preview or large printers)
// 1 = Part 1 (Left end / Nose)
// 2 = Part 2 (Middle-left segment)
// 3 = Part 3 (Middle-right segment)
// 4 = Part 4 (Right end / Tail - currently shortened by 'right_side_offset')
part_to_print = 0; 

// Tolerance gap between the interlocking joints.
// 0.1mm is tight and good for well-calibrated printers.
// Increase to 0.15 or 0.2 if the parts don't fit together after printing.
print_clearance = 0.1;   

// ============================================================================
// CORE ENCLOSURE LOGIC & SHAPES (Do not edit below unless modifying the logic)
// ============================================================================

total_length = straight_length + (2 * taper_length);
segment_length = total_length / 4;

x_mid = straight_length / 2;
x_end = (straight_length / 2) + taper_length - end_radius;
y_max = (total_width / 2) - outer_radius;
y_end = (end_width / 2) - end_radius;

// Base profile of the enclosure
module base_profile(h, r_mid, r_end) {
    hull() {
        // 🔥 RIGHT SIDE (Shortened by right_side_offset)
        translate([ x_end - right_side_offset,  y_end, 0]) cylinder(r=max(0.1, r_end), h=h);
        translate([ x_end - right_side_offset, -y_end, 0]) cylinder(r=max(0.1, r_end), h=h);
        translate([ x_mid - right_side_offset,  y_max, 0]) cylinder(r=max(0.1, r_mid), h=h);
        translate([ x_mid - right_side_offset, -y_max, 0]) cylinder(r=max(0.1, r_mid), h=h);
        
        // 🔥 LEFT SIDE (Remains in original positions, keeping backwards compatibility)
        translate([-x_mid,  y_max, 0]) cylinder(r=max(0.1, r_mid), h=h);
        translate([-x_mid, -y_max, 0]) cylinder(r=max(0.1, r_mid), h=h);
        translate([-x_end,  y_end, 0]) cylinder(r=max(0.1, r_end), h=h);
        translate([-x_end, -y_end, 0]) cylinder(r=max(0.1, r_end), h=h);
    }
}

module solid_3d(delta) { 
    base_profile(0.1, outer_radius - delta, end_radius - delta); 
}

// Generates the outer shell with bottom fillets
module outer_shell() {
    union() {
        base_profile(flange_thickness, outer_radius, end_radius);
        hull() {
            translate([0, 0, 0]) solid_3d(flange_width);
            translate([0, 0, outer_height - bottom_fillet_radius]) solid_3d(flange_width);
            for (a = [10 : 10 : 90]) {
                dz = bottom_fillet_radius * sin(a);
                dinset = bottom_fillet_radius * (1 - cos(a));
                translate([0, 0, outer_height - bottom_fillet_radius + dz])
                    solid_3d(flange_width + dinset);
            }
        }
    }
}

// Generates the internal cavity to hollow out the enclosure
module internal_cavity() {
    hull() {
        r_inner = max(0.1, bottom_fillet_radius - wall_thickness);
        z_start_inner = outer_height - wall_thickness - r_inner + 0.011;
        
        translate([0, 0, -1]) solid_3d(flange_width + wall_thickness);
        translate([0, 0, z_start_inner]) solid_3d(flange_width + wall_thickness);
        
        for (a = [10 : 10 : 90]) {
            dz_inner = r_inner * sin(a);
            dinset_inner = r_inner * (1 - cos(a));
            translate([0, 0, z_start_inner + dz_inner])
                solid_3d(flange_width + wall_thickness + dinset_inner);
        }
    }
}

// Shell base for boolean operations in the interlocking joint system
module shell_base(offset_th) {
    th = (wall_thickness / 2) + offset_th;
    th_z = (wall_thickness / 2);
    r_mid = max(0.1, bottom_fillet_radius - th_z);
    z_start = outer_height - th_z - r_mid + 0.022 + (offset_th * 0.005); 

    hull() {
        translate([0, 0, -1]) solid_3d(flange_width + th);
        translate([0, 0, z_start]) solid_3d(flange_width + th);
        for (a = [10 : 10 : 90]) {
            dz = r_mid * sin(a);
            dinset = r_mid * (1 - cos(a));
            translate([0, 0, z_start + dz])
                solid_3d(flange_width + th + dinset);
        }
    }
}

// Hardware cutouts and internal structural reinforcements
module rectangular_cutout() {
    translate([cutout_X, cutout_Y, 40]) 
    cube([cutout_length, cutout_width, 60], center=true);
}

module inner_band() {
    delta_band_outer = flange_width + 1.0; 
    delta_band_inner = flange_width + wall_thickness - 1.0; 
    
    translate([0, 0, 34]) difference() {
        base_profile(2, outer_radius - delta_band_outer, end_radius - delta_band_outer);
        translate([0, 0, -1]) base_profile(4, outer_radius - delta_band_inner, end_radius - delta_band_inner);
    }
}

module heatsink_flange() {
    z_inner = outer_height - wall_thickness;
    thickness = 3;
    outer_len = cutout_length + 10;
    outer_wid = cutout_width + 10;
    inner_len = cutout_length - 10;
    inner_wid = cutout_width - 10;

    translate([cutout_X, cutout_Y, z_inner - (thickness / 2) + 0.01])
    difference() {
        cube([outer_len, outer_wid, thickness], center=true);
        cube([inner_len, inner_wid, thickness + 1], center=true);
    }
}

// ============================================================================
// MOUNTING SYSTEM (Pillars & Holes)
// ============================================================================

module inner_mounts_mask() {
    y_wall = (total_width / 2) - flange_width;
    for (i = [0 : screws_per_side - 1]) {
        x = x_start_screw + (i * screw_step);
        translate([x, y_wall - mount_radius, -5]) hull() {
            cylinder(r=mount_radius, h=outer_height + 10);
            translate([-mount_radius, 0, 0]) cube([mount_radius*2, mount_radius + 10, outer_height + 10]);
        }
        translate([x, -y_wall + mount_radius, -5]) hull() {
            cylinder(r=mount_radius, h=outer_height + 10);
            translate([-mount_radius, -(mount_radius + 10), 0]) cube([mount_radius*2, mount_radius + 10, outer_height + 10]);
        }
    }
}

module inner_mounts_holes() {
    y_wall = (total_width / 2) - flange_width;
    for (i = [0 : screws_per_side - 1]) {
        x = x_start_screw + (i * screw_step);
        translate([x, y_wall - mount_radius, -10]) cylinder(d=inner_hole_diameter, h=outer_height + 20);
        translate([x, y_wall - mount_radius, outer_height - counterbore_depth]) cylinder(d=counterbore_diameter, h=counterbore_depth + 10);
        translate([x, -y_wall + mount_radius, -10]) cylinder(d=inner_hole_diameter, h=outer_height + 20);
        translate([x, -y_wall + mount_radius, outer_height - counterbore_depth]) cylinder(d=counterbore_diameter, h=counterbore_depth + 10);
    }
}

module additional_mounts_mask() {
    y_limit = (end_width / 2) - flange_width - wall_thickness;
    for (p = additional_mounts) {
        x = p[0]; y = p[1]; rot = p[3];
        y_target = (y > 0) ? y_limit : -y_limit;
        translate([x, y, -5]) rotate([0, 0, rot]) hull() {
            scale([1, 1.5, 1]) cylinder(r=mount_radius, h=outer_height + 10);
            translate([0, (y_target - y), 0]) scale([1, 1.5, 1]) cylinder(r=mount_radius, h=outer_height + 10);
        }
    }
}

module additional_mounts_holes() {
    for (p = additional_mounts) {
        translate([p[0], p[1], -10]) cylinder(d=inner_hole_diameter, h=outer_height + 20);
        translate([p[0], p[1], outer_height - counterbore_depth]) 
            cylinder(d=counterbore_diameter, h=counterbore_depth + 10);
    }
}

// Combines all features into the final full un-cut enclosure
module full_enclosure() {
    union() {
        difference() {
            union() {
                outer_shell();
                inner_band(); 
            }
            difference() { 
                internal_cavity(); 
                inner_mounts_mask(); 
                additional_mounts_mask();
            }
            inner_mounts_holes();
            additional_mounts_holes();
            
            rectangular_cutout(); 
        }
        heatsink_flange();
    }
}

// ============================================================================
// 3D INTERLOCKING SYSTEM (Prevents roof gaps and provides alignment)
// ============================================================================

module outer_mask_tail() {
    polygon([
        [-1000, -300], [0, -300],
        [0, -100], [20, -115], [20, -65], [0, -80],
        [0, -25], [20, -45], [20, 45], [0, 25],
        [0, 80], [20, 65], [20, 115], [0, 100],
        [0, 300], [-1000, 300]
    ]);
}

module outer_mask_straight() {
    polygon([
        [-1000, -300], [0, -300],
        [0, 300], [-1000, 300]
    ]);
}

module inner_mask_overlap() {
    polygon([
        [-1000, -300],
        [25, -300], 
        [25, 300],
        [-1000, 300]
    ]);
}

module seam_patch(cut_X, clearance) {
    z_end = outer_height - bottom_fillet_radius; 
    delta_out = flange_width + (wall_thickness / 2) - 1.0 - clearance;
    delta_in  = flange_width + (wall_thickness / 2) + 1.0 + clearance;

    intersection() {
        translate([cut_X, 0, -500]) 
            linear_extrude(1000) 
                offset(delta=clearance) outer_mask_tail();
        
        difference() {
            translate([0, 0, -50]) 
                base_profile(150, outer_radius - delta_out, end_radius - delta_out);
            translate([0, 0, -60]) 
                base_profile(170, outer_radius - delta_in, end_radius - delta_in);
        }
        translate([-1000, -1000, -50]) 
            cube([2000, 2000, 50 + z_end + 0.1]); 

        translate([0, 0, -50])
            base_profile(150, outer_radius - flange_width, end_radius - flange_width);
    }
}

module left_cut_mask(cut_X) {
    z_end = outer_height - bottom_fillet_radius; 
    union() {
        intersection() {
            translate([-1000, -1000, z_end - 0.1]) cube([2000, 2000, 1000]);
            union() {
                difference() { 
                    translate([cut_X, 0, -500]) linear_extrude(1000) outer_mask_straight(); 
                    shell_base(0.5); 
                }
                intersection() { 
                    translate([cut_X, 0, -500]) linear_extrude(1000) inner_mask_overlap(); 
                    shell_base(-0.5); 
                }
            }
        }
        intersection() {
            translate([-1000, -1000, -500]) cube([2000, 2000, 500 + z_end + 0.1]);
            union() {
                difference() { 
                    translate([cut_X, 0, -500]) linear_extrude(1000) outer_mask_tail(); 
                    shell_base(0.5); 
                }
                intersection() { 
                    translate([cut_X, 0, -500]) linear_extrude(1000) inner_mask_overlap(); 
                    shell_base(-0.5); 
                }
            }
        }
        seam_patch(cut_X, 0.01);
    }
}

module right_cut_mask(cut_X) {
    z_end = outer_height - bottom_fillet_radius; 
    
    difference() {
        translate([cut_X + 500, 0, 0]) cube([1000, 600, 600], center=true);
        union() {
            intersection() {
                translate([-1000, -1000, z_end - 0.1]) cube([2000, 2000, 1000]); 
                union() {
                    difference() { 
                        translate([cut_X, 0, -500]) linear_extrude(1000) offset(delta=print_clearance) outer_mask_straight(); 
                        shell_base(0.5); 
                    }
                    intersection() { 
                        shell_base(-0.5); 
                        translate([cut_X, 0, -500]) linear_extrude(1000) offset(delta=print_clearance) inner_mask_overlap(); 
                    }
                }
            }
            intersection() {
                translate([-1000, -1000, -500]) cube([2000, 2000, 500 + z_end + 0.1]); 
                union() {
                    difference() { 
                        translate([cut_X, 0, -500]) linear_extrude(1000) offset(delta=print_clearance) outer_mask_tail(); 
                        shell_base(0.5); 
                    }
                    intersection() { 
                        shell_base(-0.5); 
                        translate([cut_X, 0, -500]) linear_extrude(1000) offset(delta=print_clearance) inner_mask_overlap(); 
                    }
                }
            }
            seam_patch(cut_X, print_clearance);
        }
    }
}

// ============================================================================
// RENDER CACHING & FINAL SLICING
// ============================================================================

// 🔥 Hardcoded cut coordinates based on the 600mm base (185mm per segment).
// Ensures backward compatibility of joints with previous versions!
cut1 = -185;
cut2 = 0;
cut3 = 185;

if (part_to_print == 0) {
    render(convexity=10) full_enclosure(); 
} else if (part_to_print == 1) {
    render(convexity=15) intersection() { 
        render(convexity=10) full_enclosure(); 
        render(convexity=10) left_cut_mask(cut1); 
    }
} else if (part_to_print == 2) {
    render(convexity=15) intersection() { 
        render(convexity=10) full_enclosure(); 
        render(convexity=10) right_cut_mask(cut1); 
        render(convexity=10) left_cut_mask(cut2); 
    }
} else if (part_to_print == 3) {
    render(convexity=15) intersection() { 
        render(convexity=10) full_enclosure(); 
        render(convexity=10) right_cut_mask(cut2); 
        render(convexity=10) left_cut_mask(cut3); 
    }
} else if (part_to_print == 4) {
    render(convexity=15) intersection() { 
        render(convexity=10) full_enclosure(); 
        render(convexity=10) right_cut_mask(cut3); 
    }
}