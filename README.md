# Website for Rebase Conf

## Dependencies ##

### Unix ###

In most cases and if you have Ruby installed, you will be fine with running

    bundle install

This installs all necessary gems into the project directory and should work in any environment including Mac OS with System Integrity Protection.
In case you want to use your system gems, then you are probably familiar with Ruby and know what you are doing enough to not need this part.

## Building & Viewing ##

Build by:

    bundle exec jekyll --server

or:

    bundle exec jekyll serve

The generated site is available at `http://localhost:4000`


To build incrementally using BrowserSync, run:

    bundle exec jekyll browsersync --increment

There is also a `Makefile` that automates the above tasks.

## Expanding and tweaking the theme

### Basic theming
- Colors and fonts are defined using SCSS variables in `resources/<year>/css/_variables.scss`. Try changing `$color-background:` and check what happens!

### (S)CSS
- The theme uses Bootstrap v4 grid together with media query mixins mimicking `media-breakpoint-up` and `media-breakpoint-down` Bootstrap mixins. Breakpooints also correspond with Bootstrap v4 but can be changed in `resources/<year>/css/_variables.scss`.
- CSS class names follow [BEM methodology](http://getbem.com/introduction/).
- All SCSS files are imported to `resources/<year>/css/app.scss`.
- SCSS mixins are the preferred way of re-using CSS properties between elements. Re-using CSS classes should be avoided.

### JavaScript
- To avoid generating a single page for every presentation, overlays are filled with content using existing elements + text content generated into
JS arrays. DOM manipulation uses [jQuery](https://jquery.com/). Please see `resources/<year>/js/app.js` for source code.
- Overlays use [History API](https://developer.mozilla.org/en-US/docs/Web/API/History) to manipulate browser location and allow sharing links to overlays. In case a location hash corresponding to a talk or a keynote speaker is detected, the overlay is opened automatically.

### New sections
- The easiest way is to duplicate a section similar to an existing section (e.g. About for a new text section).
- Every section should have a corresponding SCSS file in `resources/<year>/css/`.

## Content

- `_data/2020.yml` contains an example conference configuration including comments.

### Photos

- Photos for speakers need to be stored in `resources/<year>/img/people`.
- Filenames have to match speaker ids in the data file.
- JPG format only, resolution 100x100px (250x250px for photos in the Keynote speakers section).
- Including Retina version, resolution 200x200px (500x500px for photos in the Keynote speakers section).
- Photo quality should be 60% maximum, anything more is just a waste of bandwith.

### Sponsors

- SVG logos are highly recommended. You can use [SVGOMG](https://jakearchibald.github.io/svgomg/) to optimise files.
- There are reasonable defaults for logo sizes, however they do not work well for some aspect ratios (e.g. logos
too square-ish). You can use `resources/<year>/css/_sponsors.scss` to tweak them.