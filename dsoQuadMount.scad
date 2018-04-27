
eps = 0.01;
thickness = 2;

inner_width = 98;
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

module beveled_profile(bevel_bottom_corner=true) {
    start_points = bevel_bottom_corner ? [
            [0, 0],
            [corner_inner_bevel_radius, 0],
            [corner_inner_radius, bevel_height],
        ] : [
            [0, 0],
            [corner_inner_radius, 0],
        ];

    points = concat(start_points, [
        [corner_inner_radius, inner_height - bevel_height],
        [corner_inner_bevel_radius, inner_height],
        [0, inner_height],
    ]);
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

corner();
