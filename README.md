# Pyxis

A simple script that provides mechanisms to quickly find and open files.

A major design goal was ease-of-installation; the script does not depend on
vim being compiled with support for any "special" features. This comes at the
price of not being able to (feasibly) add fancy things like approximate string
matching (overrated anyway, right) etc.


## Installation

http://vimcasts.org/episodes/synchronizing-plugins-with-git-submodules-and-pathogen/


## Usage

`:Pyxis` opens an "input field". A list containing matching files will be
displayed as you start typing (assuming there are files that match your
search criteria in your current working directory).

An in-memory cache will be populated during the first run. You can use
`:PyxisUpdateCache` to manually update the cache.

Something like the following to your .vimrc might be nice:

    noremap <leader>e :Pyxis<CR>
    noremap <leader>E :PyxisUpdateCache<CR>

`<Tab>`, `<S-Tab>`, `<Down>` and `<Up>` cycles between entries in the list.

`<CR>` opens selected file in currently active window. `<C-h>` and `<C-v>`
opens the file in horizontal and vertical splits, respectively.

`/` and `_` in quries work as matching delimiters. You can, for example, type
`do/` to list all files in `doc/`, or `h_w` to match a file named
`hello_world.c`. 


## Caveats

The script relies on `find` to populate the cache at the moment, but I'm
evaluating an implementation that uses the built-in `globpath` instead.

Current state of the project: mostly works for me and I prefer it over other
solutions.

The script stores a list of all files in cwd in an in-memory cache. You
currently need to manually update the cache when you remove or add files. I
might fix this some day.

I'll also have another look at how exclusion of files based on patterns could
work better.
