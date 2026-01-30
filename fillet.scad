include <globals.scad>

module fillet2d ( radius, outerFirst = true ) {
	coeff = outerFirst ? 1 : -1;
	offset ( coeff * radius ) {
		offset ( -2 * coeff * radius ) {
			offset ( coeff * radius ) {
				children();
			}
		}
	}
}

module fillet_cutter ( r, h ) {
	difference () {
		translate ( [ 0, 0, -h / 2 - $eps ] ) {
			cube ( [ r + $eps, r + $eps, h + 2 * $eps ] );
		}

		cylinder ( r = r, h = h + 2 * $eps );
	}
}

module fillet_cutter2d ( r ) {
	translate ( [ -r, -r ] ) {
		difference () {
			square ( [ r + $eps, r + $eps ] );

			circle ( r = r );
		}
	}
}