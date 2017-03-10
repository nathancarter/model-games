
# Model Games

## Purpose

This repository is fully explained on
[its website](http://nathancarter.github.io/model-games),
which is also hosted on GitHub.

## Build process

If you clone the project and want to build it, you will need
[CoffeeScript](http://www.coffeescript.org) installed.  Then
just run this in the project folder:

```
coffee -c *.litcoffee
```

This will (re)generate corresponding `.js` files in the same
folder, which are used by the included `index.html`.

Note that this project is its own website, because GitHub has
(thankfully) moved beyond the `gh-pages` concept.

## Customization

If you want to write your own logic games using this file,
follow these steps.

 1. Create an HTML file that will contain the list of games.
 1. Include jQuery and Bootstrap, as [the index file](index.html)
    in this repository does, in the page's head.
 1. Somewhere in that file, where you wish the list of games to
    appear, create an HTML Element (such as a DIV) whose ID is
    `modelList`.
 1. Create a script that defines your games.  Follow the example
    in this repository, in
    [my-games.litcoffee](my-games.litcoffee).  That file contains
    only minimal explanations of what it's doing, because it
    assumes that you've read the file on which it depends,
    [model-games.litcoffee](model-games.litcoffee).  Because
    these files are in Literate CoffeeScript, they're very
    easy to read on GitHub.
 1. If you wrote your files in CoffeeScript instead of
    JavaScript, be sure to recompile them as described above.
 1. Import both `model-games.js` and your (compiled)
    game definition file at the end of your page body, just as
    [the index file](index.html) in this repository does.
 1. Load your page and it should function.

## License

[LGPL](https://www.gnu.org/licenses/lgpl-3.0.en.html)

