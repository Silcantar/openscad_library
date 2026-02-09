include <globals.scad>

use <animation.scad>
use <fillet.scad>

$fa = 10;
$fs = 0.1;

/* [Hidden] */
filletRadius = 1;
lip_size = [ 15, 15, 1 ];
lower_size = [ 14, 14, 2.5 ];
upper_chamfer = 1.4;
upper_size = [ 13.7, 13.2, 2.4 ];
upper_offset = 0.45;
upper_taperDistance = 0.25;
slider_lower = 1;
stem_size = [ 4, 1, 3.2 ];
slider_size = [ 9.4, 4.5, stem_size.z + slider_lower ];
slider_outerDiameter = 6.5;
slider_innerDiameter = 4.6;
centerPin_diameter = 4.8;
centerPin_height = 3;
centerPin_taperDiameter = 4.2;
centerPin_taperHeight = 1;
pin_size = [ 1, 0.3, 3 ];
pin_positions = [ [ 2.6, -5.75 ], [ -4.4, -4.7 ] ];
pin_rotations = [ 0, 90 ];
ledOpening_size = [ 5, 3 ];
ledOpening_location = [ 5, 1 ];
hole_size = [ 2.4, 2 ];
max_travel = 3.2;

/* [Color] */
color = "Red"; //["Banana","Blue","Brown","Chocolate","Heron","Red","Strawberry","Aloe","Cowberry","Daisy","Moss","Panda","Wisteria"]

/* [Hidden] */
black = [ 0.2, 0.2, 0.2, 1 ];
clear = [ 0.8, 0.8, 0.8, 0.5 ];

// Map GLP switch type to CSS colors.
colors = object ( [
//    Name            Lower                 Upper           Slider
    // Gateron brand
    [ "Banana",	    [ black,                clear,          "Khaki",			] ],
    [ "Blue",		[ black,                clear,          "Blue",				] ],
    [ "Brown",		[ black,                clear,          "SaddleBrown",		] ],
    [ "Chocolate",	[ "SaddleBrown",        "AntiqueWhite", "Sienna",			] ],
    [ "Heron",      [ "RoyalBlue",          "White",        "Gray"              ] ],
    [ "Red",		[ black,                clear,          "Red",				] ],
    [ "Strawberry", [ "LightPink",          "White",        "LightPink"         ] ],
    // Nuphy brand
    [ "Aloe",		[ "YellowGreen",        clear,          "YellowGreen",		] ],
    [ "Cowberry",	[ "Crimson",            clear,          "Crimson"			] ],
    [ "Daisy",		[ "Salmon",             clear,          "Salmon"			] ],
    [ "Moss",		[ "DarkOliveGreen",     clear,          "DarkOliveGreen"	] ],
    [ "Panda",		[ "Gray",               "Gray",         black				] ],
    [ "Wisteria",	[ "MediumSlateBlue",    clear,          "MediumSlateBlue"	] ],
] );

ks33 ( travel = max_travel * oscillate() );

module ks33 ( color = color, travel = 0 ) {
    color ( colors[color][0] ) {
        lower_housing();
    }

    translate ( [ 0, 0, lip_size.z / 2 - $eps ] ) {
        color ( colors[color][1] ) {
            upper_housing();
        }
    }

    translate ( [
        0,
        0,
        upper_size.z + ( lip_size.z + slider_size.z ) / 2 - slider_lower - travel
    ] ) {
        color ( colors[color][2] ) {
            stem();
        }
    }

    translate ( [ 0, 0, -lower_size.z ] ) {
        for ( i = [ 0 : 1 ] ) {
            translate ( pin_positions[i] ){
                rotate ( pin_rotations[i] ) {
                    pin();
                }
            }
        }
    }
}

module lower_housing () {
/********* Lower housing *********/
    // Center lip
    linear_extrude ( lip_size.z ) {
        fillet2d ( filletRadius ) {
            square ( [ lip_size.x, lip_size.y ], center = true );
        }
    }

    translate ( [ 0, 0, $eps - lower_size.z ] ) {
        linear_extrude ( h = lower_size.z + $eps ) {
            fillet2d ( filletRadius ) {
                square ( [ lower_size.x, lower_size.y ], center = true );
            }
        }
    }

    // Center pin
    translate ( [ 0, 0, -lower_size.z - centerPin_height + centerPin_taperHeight ] ) {
        cylinder (
            d = centerPin_diameter,
            h = centerPin_height - centerPin_taperHeight + $eps
        );
        translate ( [0, 0, -centerPin_taperHeight ] ) {
            cylinder (
                d1 = centerPin_taperDiameter,
                d2 = centerPin_diameter,
                h = centerPin_taperHeight,
            );
        }
    }
}

module upper_housing () {
/********* Upper Housing *********/

    difference () {
        linear_extrude (
            h = upper_size.z + $eps,
            scale = 1 - upper_taperDistance / upper_size.x
        ) {
            *square ( [ upper_size.x, upper_size.y ], center = true );
            x = upper_size.x / 2;
            y = upper_size.y / 2;
            c = upper_chamfer;
            o = upper_offset;

            fillet2d ( 0.2 ){
                polygon ( [
                    [ x,        y + o       ],
                    [ x,        -y + c + o  ],
                    [ x - c,    -y + o      ],
                    [ -x + c,   -y + o      ],
                    [ -x,       -y + c + o  ],
                    [ -x,       y + o       ],
                ] );
            }
        }

        translate ( [ 0, 0, slider_size.z / 2 - $eps ] ) {
            scale ( 1 + $eps ) {
                stem ( cut = true );
            }
        }
    }
}

module stem ( cut = false ) {
/********* Stem *********/
    difference () {
        union () {
            cube ( slider_size, center = true );
            cylinder (
                d = slider_outerDiameter,
                h = slider_size.z,
                center = true
            );
        }

        if ( !cut ) {
            translate ( [ 0, 0, slider_lower / 2 + $eps ] ) {
                cylinder (
                    d = slider_innerDiameter,
                    h = stem_size.z + $eps,
                    center = true,
                );
            }
        }
    }

    translate ( [ 0, 0, slider_lower / 2 - $eps ] ){
        for ( r = [ 0, 90] ) {
            rotate ( r ) {
                cube ( stem_size + [ 0, 0, $eps ], center = true );
            }
        }
    }
}

module pin () {
    color ( "Goldenrod" ) {
        translate ( [ 0, 0, -( pin_size.z - pin_size.x / 2 ) / 2 ] ) {
            cube ( pin_size + [ 0, 0, $eps - pin_size.x / 2 ], center = true );
        }

        translate ( [ 0, 0, -pin_size.z + pin_size.x / 2 ] ) {
            rotate ( [ 90, 0, 0 ] ){
                cylinder ( d = pin_size.x, h = pin_size.y, center = true );
            }
        }
    }
}