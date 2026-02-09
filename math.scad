$fa = 10;
$fs = 0.1;

// Vector Math.
// Product of the elements of a vector.
function product ( v, i = 0, r = 1 ) = ( i < len ( v ) ) ? product ( v, i + 1, r * v[i] ) : r;

// Sum of the elements of a vector.
function sum ( v, i = 0, r = 0 ) = ( i < len ( v ) ) ? sum ( v, i + 1, r + v[i] ) : r;

// Element-wise vector multiplication.
function v_mul ( v1, v2 ) = [
	for ( i = [ 0 : min ( len ( v1 ) - 1, len ( v2 ) - 1 ) ] ) (
		v1[i] * v2[i]
	)
];

// Slice a vector.
function v_slice ( v, start = 0, end = undef ) = (
	let (
		end2 = is_undef ( end ) ? len ( v ) : end,
	) [
		for ( i = [ start : end2 ] ) v[i]
	]
);

// Slice a matrix.
function m_slice ( m, start = [ 0, 0 ], end = undef ) = (
	let (
		end2 = is_undef ( end ) ? [ len ( m ) - 1, len ( m ) - 1 ] : end,
	) [
		for ( i = [ start.y : end2.y ] ) [
			for ( j = [ start.x : end2.x ] ) m[i][j]
		]
	]
);

// Convert a nxn rotation matrix to a (n+1)x(n+1) affine matrix.
function to_affine ( m ) = concat (
	[ for ( row = m ) concat ( row, [ 0 ] ) ],
	[ [ for ( i = [ len ( m ) : -1 : 0 ] ) ( i == 0 ) ? 1 : 0 ] ]
);

// // Rotation Matrices.
// 2d rotation matrix.
function rot2d ( angle, affine = true ) = (
	let (
		dim = affine ? 2 : 1,
	) m_slice (
		rot3d ( [ 0, 0, angle ] ),
		end = [ dim, dim ],
	)
);

// // 3d rotation matrix.
function rot3d ( angles, affine = true ) = (
	let (
		a = angles,
		dim = affine ? 3 : 2,
	) m_slice (
		[
			[
				cos(a.z) * cos(a.y),
				cos(a.z) * sin(a.y) * sin(a.x) - sin(a.z) * cos(a.x),
				cos(a.z) * sin(a.y) * cos(a.x) - sin(a.z) * sin(a.x),
				0
			],
			[
				sin(a.z) * cos(a.y),
				sin(a.z) * sin(a.y) * sin(a.x) + cos(a.z) * cos(a.x),
				sin(a.z) * sin(a.y) * cos(a.x) - cos(a.z) * sin(a.x),
				0
			],
			[
				-sin(a.y),
				cos(a.y) * sin(a.x),
				cos(a.y) * cos(a.x),
				0
			],
			[ 0, 0, 0, 1 ]
		],
		end = [ dim, dim ],
	)
);

// 2d translation matrix.
function trans2d ( v ) = [
	[	1,	0,	v.x	],
	[	0,	1,	v.y	],
	[	0,	0,	1	]
];

// 3d translation matrix.
function trans3d ( v ) = [
	[	1,	0,	0,	v.x	],
	[	0,	1,	0,	v.y	],
	[	0,	0,	1,	v.z	],
	[	0,	0,	0,	1	]
];

// Identity matrix of dimension <dim>.
function id ( dim ) = [
	for ( i = [ 1 : dim ] ) [
		for ( j = [ 1 : dim ] ) (
			( i == j ) ? 1 : 0
		)
	]
];

function skew2d (
	v = undef,
	distance = false,
	affine = true,
	xy = 0,
	yx = 0
) = let (
	v2 = is_undef ( v ) ? (
		[ xy, 0, yx, 0, 0, 0 ]
	) : (
		[ v[0], 0, v[1], 0, 0, 0 ]
	),
	dim = affine ? 2 : 1,
) m_slice ( skew3d ( v2, distance ), end = [ dim, dim ] );

function skew3d (
	v = undef,
	slope = false,
	affine = true,
	xy = 0,
	xz = 0,
	yx = 0,
	yz = 0,
	zx = 0,
	zy = 0,
) = let (
	v2 = (
		is_undef ( v ) ? (
			slope ? (
				[ xy, xz, yx, yz, zx, zy ]
			) : (
				[ tan ( xy ), tan ( xz ), tan ( yx ), tan ( yz ), tan ( zx ), tan ( zy ) ]
			)
		) : (
			slope ? (
				v
			) : (
				[ for ( i = [ 0 : len ( v ) - 1 ] ) tan ( v[i] ) ]
			)
		)
	),
	dim = affine ? 3 : 2,
) m_slice (
	[	[ 1,		v2[0],	v2[1],	0	],
		[ v2[2],	1,		v2[3],	0	],
		[ v2[4],	v2[5],	1,		0	],
		[ 0,		0,		0,		1	]	],
	end = [ dim, dim ],
);


// Test circular intepolation.
module test_ci (){
	point1 = [ 0, 0 ]; // [ -10 : 0.1 : 10 ]
	dist = 1;
	point2 = dist * [ cos ( 360 * $t ), sin ( 360 * $t ) ] + point1;
	radius = 2.0; // [ 0 : 0.01 : 10 ]

	translate ( point1 ) color ( "green" ) cylinder ( d = 0.2, h = 0.5 );
	translate ( point2 ) color ( "red" ) cylinder ( d = 0.2, h = 0.5 );

	for ( f = [ 0 : 0.1 : 1 ] ) {
		let ( c = circular_interpolation ( f, point1, point2, radius, object = true ) ) {
			echo ( c );
			translate ( c.p ) {
				cylinder ( d = 0.1, h = 1 );
			}
			translate ( c.o ) cylinder ( r = radius, h = 0.2);
		}
	}
}

// Interpolate between two points using a circular arc with the given radius.
// Arc curvature is counterclockwise from point 1 to point 2.
// If radius is less than half the distance between the points, do linear interpolation.
function circular_interpolation (
	f,
	point1,
	point2,
	radius,
	object = false,
) = ( radius >= norm ( point2 - point1 ) / 2 ) ? (
	let (
		// Circular interpolation.
		v = point2 - point1, // Chord of the arc between point1 and point2.
		midpoint = point1 + v / 2, // Midpoint of the chord.
		b = sqrt ( radius ^ 2 - norm ( v / 2 ) ^ 2 ), // Distance from chord midpoint to arc center.
		origin = midpoint + b * [ [ 0, -1 ], [ 1, 0 ] ] * v / norm ( v ), // Arc center.
		normal1 = point1 - origin,
		angle1 = atan ( normal1.y / normal1.x ) + ( normal1.x < 0 ? 180 : 0 ), // Angle between x axis and point1 radius.
		angle2 = angle1 + 2 * asin ( norm ( v ) / 2 / radius ), // Angle between x axis and point2 radius.
		angle = f * ( angle2 - angle1 ) + angle1, // Angle between x axis and output point radius.
		point = origin + radius * [ cos ( angle ), sin ( angle ) ],
	) (
		object ? object ( p = point, o = origin ) : point
	)
) : (
	// Linear interpolation.
	let (
		point = ( point2 - point1 ) * f + point1,
	) (
		object ? object ( p = point, o = point1) : point
	)
);