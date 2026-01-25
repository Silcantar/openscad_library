
// Conditional background
module cb ( cond = $test ) {
	ct ( $test ) {
		children(0);

		%children(0);
	}
}

// Conditional highlight
module ch ( cond = $test ) {
	ct ( $test ) {
		children(0);

		#children(0);
	}
}

// Conditional test
module ct ( cond = $test ) {
	if ( cond ) {
		if ( $children >= 2 ) {
			children(1);
		}
	} else {
		children(0);
	}
}