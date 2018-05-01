
eps = 0.01;
thickness = 1.5;

inner_width = 98;
inner_length = 56;
inner_width_with_bevel = 93;
bevel_width = (inner_width - inner_width_with_bevel)/2;

inner_height = 13.75;
inner_outset_height = 9.5;
bevel_height = (inner_height - inner_outset_height)/2;
outer_height = inner_height + thickness*2;

corner_inner_radius = 6;
corner_inner_bevel_radius = (corner_inner_radius - bevel_width);
corner_outer_radius = corner_inner_radius + thickness;

corner_overhang = 2;

bolt_hole_radius = 1/4 * 25.4 / 2;
nut_flats_width = 7/16 * 25.4;
nut_corners_width = nut_flats_width/cos(180/6);
nut_height = 7/32 * 25.4;
nut_slop = 0.2;

nut_holder_width = nut_flats_width + thickness * 2;
nut_holder_length = thickness + nut_height + thickness;
nut_holder_height = outer_height;

connecting_beam_width = corner_outer_radius + corner_overhang;

module beveled_profile(bevel_top_corner=true, bevel_bottom_corner=true) {
    start_points = bevel_bottom_corner ? [
            [0, 0],
            [corner_inner_bevel_radius, 0],
            [corner_inner_radius, bevel_height],
        ] : [
            [0, 0],
            [corner_inner_radius, 0],
        ];
    end_points = bevel_top_corner ? [
        [corner_inner_radius, inner_height - bevel_height],
        [corner_inner_bevel_radius, inner_height],
        [0, inner_height],
    ] : [
        [corner_inner_radius, inner_height],
        [0, inner_height],
    ];

    points = concat(start_points, end_points);
    polygon(points=points);
}

module beveled_profile_holder() {
    translate([0, thickness]) {
        difference() {
            offset(delta=thickness) {
                beveled_profile(bevel_bottom_corner=false);
            }
            beveled_profile();
            translate([-thickness, -thickness-eps]) {
                square([thickness+eps, outer_height+2*eps]);
            }
            translate([0, inner_height]) {
                square([corner_inner_bevel_radius, thickness+2*eps]);
            }
        }
    }
}

module corner() {
    union() {
        rotate([90, 0, 0]) {
            linear_extrude(height=corner_overhang) {
                beveled_profile_holder();
            }
        }
        rotate_extrude(angle=90, $fn=60) {
                beveled_profile_holder();
        }
        translate([-corner_overhang, 0, 0]) {
            rotate([90, 0, 90]) {
                linear_extrude(height=corner_overhang) {
                    beveled_profile_holder();
                }
            }
        }
    }
}

module beveled_profile_sturdy() {
    points = [
        [0, 0],
        [0, thickness],
        [bevel_width, thickness + bevel_height],
        [bevel_width, thickness + inner_height - bevel_height],
        [0, thickness + inner_height],
        [0, thickness + inner_height + thickness],
        [bevel_width + eps, thickness + inner_height + thickness],
        [bevel_width + eps, 0],
    ];
    polygon(points=points);
}

module nut_holder() {
    translate([0, -nut_holder_length, 0]) {
        difference() {
            union() {
                translate([-nut_holder_width/2, 0, 0]) {
                    cube([nut_holder_width, nut_holder_length, nut_holder_height]);
                }

                translate([nut_holder_width/2, nut_holder_length + bevel_width, 0]) {
                    rotate([90, 0, -90]) {
                        linear_extrude(height=nut_holder_width) {
                            beveled_profile_sturdy();
                        }
                    }
                }
            }

            // 1/4-20 nut
            translate([0, nut_holder_length - nut_height - thickness, nut_holder_height/2]) {
                rotate([-90, 90, 0]) {
                    linear_extrude(height=nut_height + thickness + bevel_width + eps) {
                        circle(d=nut_corners_width + nut_slop, $fn=6);
                    }
                }
            }
            // 1/4" bolt hole
            translate([0, -eps, nut_holder_height/2]) {
                rotate([-90, 0, 0]) {
                    cylinder(h=thickness+2*eps, r=bolt_hole_radius + nut_slop, $fn=20);
                }
            }
        }
    }
}


module dso_quad_mount() {
    union() {
        nut_holder();

        // Upper right
        translate([inner_width/2 - corner_inner_radius, inner_length - corner_inner_radius, 0]) {
            corner();
        }
        // Upper left
        translate([-inner_width/2 + corner_inner_radius, inner_length - corner_inner_radius, 0]) {
            mirror([1, 0, 0]) {
                corner();
            }
        }
        // Lower left
        translate([-inner_width/2 + corner_inner_radius, corner_inner_radius, 0]) {
            mirror([1, 1, 0]) {
                corner();
            }
        }
        // Lower right
        translate([inner_width/2 - corner_inner_radius, corner_inner_radius, 0]) {
            mirror([0, 1, 0]) {
                corner();
            }
        }

        // Connecting beams
        translate([-inner_width/2 + corner_inner_radius, -thickness, 0]) {
            cube([inner_width - corner_inner_radius * 2, connecting_beam_width, thickness]);
        }
        translate([-inner_width/2 + corner_inner_radius, inner_length + thickness - connecting_beam_width, 0]) {
            cube([inner_width - corner_inner_radius * 2, connecting_beam_width, thickness]);
        }
        translate([-inner_width/2 - thickness, corner_inner_radius, 0]) {
            cube([connecting_beam_width, inner_length - corner_inner_radius * 2, thickness]);
        }
        translate([inner_width/2 + thickness - connecting_beam_width, corner_inner_radius, 0]) {
            cube([connecting_beam_width, inner_length - corner_inner_radius * 2, thickness]);
        }
    }
}

dso_quad_mount();

%translate([-inner_width/2, 0, 0]) {
    cube([inner_width, inner_length, inner_height]);
}

