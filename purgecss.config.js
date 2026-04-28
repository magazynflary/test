module.exports = {
    content: ['public/**/*.html'],
    css: ['public/css/style.css'],
    output: 'public/css/',
    // Theme toggle sets data-theme via JS; attribute never appears in static HTML.
    safelist: {
        greedy: [/^\[data-theme/],
    },
};
