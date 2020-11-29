#!/bin/bash
# Run this script in the root of a template directory to scan all .html files
# and purge unused tailwind css selectors. it will also fetch alpinejs and
# minify files for production
#
# USAGE:
#    $ cd path/to/templates
#    $ mkassets.sh
#       ...
#    $ ls tailwind.min.css alpine.min.js
#
# This script will use npm to fetch and build the CSS and JS files used by html
# templates. It will create a _build directory which can be removed at any
# time (if not removed, be sure to .gitignore it).

mkdir -p _build
cd _build

if [ ! -f "styles.css" ]; then
	cat <<-EOF > styles.css
	@tailwind base;
	@tailwind components;
	@tailwind utilities;
	EOF
fi

if [ ! -f "tailwind.config.js" ]; then
	cat <<-EOF > tailwind.config.js
	module.exports = {
	  purge: [
		'../**/*.html'
	  ],
	  darkMode: false, // or 'media' or 'class'
	  theme: {
	    extend: {},
	  },
	  variants: {
	    extend: {},
	  },
	  plugins: [
	    require('@tailwindcss/forms'),
	    require('@tailwindcss/typography'),
	    require('@tailwindcss/aspect-ratio'),
	  ],
	}
	EOF
fi


if [ ! -f "package.json" ]; then
	npm init -y
	npm install alpinejs minify tailwindcss postcss autoprefixer tailwindcss-cli
	npm install @tailwindcss/forms @tailwindcss/typography @tailwindcss/aspect-ratio
fi

# build a dev-mode version of the CSS (no purging)
npx tailwindcss-cli build styles.css -o tailwind.full.css

# build a purged version of the CSS
NODE_ENV=production npx tailwindcss-cli build styles.css -o tailwind.css
NODE_ENV=production npx minify tailwind.css > tailwind.min.css
NODE_ENV=production npx minify node_modules/alpinejs/dist/alpine.js >alpine.min.js

# copy the final/minified versions back up to the root
cp tailwind.full.css tailwind.min.css alpine.min.js ..

####
#cd ..
#rm -fR _build
