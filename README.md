# pobls.vim
pobls.vim enables display of buffer list.

## Demo
![pobls](https://user-images.githubusercontent.com/58209438/114305090-9450ba80-9b11-11eb-8a9e-0978f6779d3b.gif)

## Usage

```
:Pobls
<cr> - open a buffer in the current window
 s   - open a buffer into a split window
 v   - open a buffer into a vertical window
```

## Options
- Show unlisted buffer
  ```vim
  let g:pobls_show_unlisted_buffers = 1 
  ```
- You can also use regular expressions to exclude buffers(eliminate matches)<br>
  Note: very magic is used
  ```vim
  let g:pobls_ignore_pattern = [
  \ '^VS.Vim.Buffer',
  \]
  ```

## Licence
MIT
