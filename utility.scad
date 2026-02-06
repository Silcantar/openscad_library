/*******************************************************************************\
|								Global Functions								|
\*******************************************************************************/

// Create a dictionary from a list of key-value pairs.
//
// If there are duplicate keys in the list, only the value for the first key
// will be returned.
//
// Example:
//		mydict = function ( key ) dictionary ( [ [ 0, "foo" ], [ 1, "bar" ] ], key );
//		echo ( mydict ( 1 ) ); // Prints "bar".
function dictionary ( keyvals, key ) = [
	for ( i = keyvals ) if ( i[0] == key ) i[1]
][0];

// Get the index of the last member of a vector.
function last ( vector ) = len ( vector ) - 1;

// Module that does nothing.
module nothing () {}

// If *var* is not already a number, evaluate it as a boolean and return 1 if
// true and 0 if false.
function bool_to_num ( var ) = is_num ( var ) ? var : ( var ? 1 : 0 );

// Absolute value function that supports iterating over a list.
function abs2 ( var ) = (
	is_list ( var ) ? [ for ( i = [ 0 : len ( var ) - 1 ]) abs ( var[i] ) ] :
	abs ( var )
);