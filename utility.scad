/*******************************************************************************\
|								Global Functions								|
\*******************************************************************************/

// Create a dictionary from a list of key-value pairs.
//
// If there are duplicate keys in the list, only the value for the first key
// will be returned.
function dictionary ( keyvals, key ) = [
	for ( i = keyvals ) if ( i[0] == key ) i[1]
][0];

// Get the index of the last member of a vector.
function last ( vector ) = len ( vector ) - 1;