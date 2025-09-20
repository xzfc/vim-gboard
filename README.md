# gboard.vim

Vim plugin that adds the `gb` command ("**g**oto clip**b**oard")
that opens the file whose name is found in the system clipboard,
similar to the built-in [`gf` command ("goto file")](https://vimhelp.org/editing.txt.html#gf).

It lets you quickly jump to a file mentioned in another terminal window,
be it an output of `grep -rn`, `rg`, compiler error message, or a stack trace.
Just select a line containing the file path, then `gb` in Vim to open it.
The selection does not need to be precise, as long as the file path is present somewhere.

See [`:help gboard`](doc/gboard.txt) for details.
Licensed under the terms of [Unlicense](UNLICENSE).

Alternatives to this plugin:
- `:e <C-r>+`
- `:nnoremap <silent> gb :execute "edit " . @+<CR>`
- [vinhtiensinh/clipboard_file_open](https://github.com/vinhtiensinh/clipboard_file_open)
