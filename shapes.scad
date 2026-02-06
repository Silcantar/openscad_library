use <fillet.scad>
use <math.scad>
use <utility.scad>

$fa = 10;
$fs = 0.1;
$eps = 0.01;

// Test
!square ( l = 5, w = -10, r = 1, center = [ 0, 1 ] );

square ( [ 10, 10 ], center = [ true, false ], radius = 5 );

cube ( [ 10, 10, 5 ], center = true );

cube ( h = 10, l = 5, w = 5, r = 3, center = [ 1, 1, 0 ] );

// Override the default square module.
// This version supports:
//	- Negative dimensions.
//	- Rounding the corners.
//	- Centering along one axis or the other. *center* parameter may be either
//	  boolean or a vec2 specifying which axes to center on.
//	- width/w and length/l parameters for size in the x- and y-directions,
//	  respectively.
module square (
	size,
	center = undef,
	l = undef,
	length = 1,
	r = undef,
	radius = 0,
	w = undef,
	width = 1,
) {
	let (
		length = is_undef ( l ) ? length : l,
		width = is_undef ( w ) ? width : w,
		size = is_undef ( size ) ? [ width, length ] : size,
		rad = is_undef ( r ) ? radius : r,
		radius = (
			( rad >= min ( abs2 ( size ) ) / 2 ) ? (
				min ( abs2 ( size ) ) / 2 - $eps
			) : (
				rad
			)
		),
		center = (
			( is_undef ( center ) || !center ) ? (
				[ 0, 0 ]
			) : (
				is_bool ( center ) ? [ 1, 1 ] : center
			)
		),
	) {
		translate ( [ for ( i = [ 0, 1 ] ) -bool_to_num ( center[i] ) * size[i] / 2 ] ) {
			fillet2d ( radius ) {
				polygon ( [
					[ 0, 		0 		],
					[ size.x, 	0		],
					[ size.x,	size.y	],
					[ 0,		size.y	]
				] );
			}
		}
	}
}

module cube (
	size,
	center = undef,
	h = 1,
	height = undef,
	l = 1,
	length = undef,
	r = 0,
	radius = undef,
	w = 1,
	width = undef,
) {
	let (
		height = is_undef ( height ) ? h : height,
		length = is_undef ( length ) ? l : length,
		width = is_undef ( width ) ? w : width,
		size = is_undef ( size ) ? [ width, length, height ] : size,
		rad = is_undef ( radius ) ? r : radius,
		radius = (
			( rad >= min ( abs2 ( size ) ) / 2 ) ? (
				min ( abs2 ( size ) ) / 2 - $eps
			) : (
				rad
			)
		),
		center = (
			( is_undef ( center ) || !center ) ? (
				[ 0, 0, 0 ]
			) : (
				is_bool ( center ) ? [ 1, 1, 1 ] : center
			)
		),
	) {
		if ( radius == 0 ) {
			linear_extrude ( h = size.z, center = ( center.z != 0 ) ) {
				square ( size.xy, center = center.xy );
			}
		} else {
			translate ( [ for ( n = [ 0 : 2 ] ) -bool_to_num ( center[n] ) * size[n] / 2 ] ) {
				hull () {
					for ( i = [ 0, 1 ], j = [ 0, 1 ], k = [ 0, 1 ] ) {
						let ( u = [ i, j, k ] ) {
							translate ( v_mul ( u, size ) - 2 * radius * u + radius * [ 1, 1, 1 ] ) {
								sphere ( r = radius );
							}
						}
					}
				}
			}
		}
	}
}