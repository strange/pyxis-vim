# Pyxis

A quick way to open files relying on external dependencies such as
interpreters or compilers. The previous statement is not entirely true as the
script uses `find` to load the cache, but this can be configured to use the
built-in `globpath` command instead.

No fancy features such as approximate string matching here. `/` works as a
matching delimiter though, so you can input `do/` to list all files in `doc/`
for example.

## Installation

http://vimcasts.org/episodes/synchronizing-plugins-with-git-submodules-and-pathogen/

## Mappings

Add something like this to your .vimrc:

    noremap <leader>e :Pyxis<CR>
    noremap <silent> <leader>E :PyxisUpdateCache<CR>

## Caveats

Current state of the project: mostly works for me and I prefer it over other
solutions.

The script stores a list of all files in cwd in an in-memory cache. You
currently need to manually update the cache when you remove or add files. I'll
fix this some day.

I'll also have another look at how exclusion of files based on patterns could
work better.
