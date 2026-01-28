
rainbow_colors = [
    [ 1.0, 0.6, 0.6 ],
    [ 0.9, 0.7, 0.6 ],
    [ 0.8, 0.8, 0.6 ],
    [ 0.7, 0.9, 0.6 ],
    [ 0.6, 1.0, 0.6 ],
    [ 0.6, 0.9, 0.7 ],
    [ 0.6, 0.8, 0.8 ],
    [ 0.6, 0.7, 0.9 ],
    [ 0.6, 0.6, 1.0 ],
    [ 0.7, 0.6, 0.9 ],
    [ 0.8, 0.6, 0.8 ],
    [ 0.9, 0.6, 0.7 ],
];

module rainbow (
    index,
    shade = 1.0,
    more_colors = false,
    opacity = 1.0,
) {
    index2 = ( more_colors ? 1 : 2 ) * index % len ( rainbow_colors );
    color (
        concat (
            shade * rainbow_colors[index2],
            [ opacity ]
        )
    ) {
        children();
    }
}