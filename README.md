# ARCHIVED
# MOVED TO: https://codeberg.org/gwid/modeline.hx 

# modeline.hx
Helix Plugin for modeline

# Installation
```sh
git clone https://github.com/mattwparas/helix.git -b steel-event-system
```

then build/install the helix fork with:
```sh
cargo xtask steel
```

to install the plugin with forge:
```sh
forge pkg install --git https://codeberg.org/gwid/modeline.hx.git
```

add the lines to your scm file to configure the modeline

```scheme
(require "modeline/modeline.scm")

;; Make sure to put these AFTER your lsp configs in steel so that the document is reloaded with the LSP
;; register the modeline to automatically run on save/open
(modeline-enable)

;; this steel function refreshes the modeline, you can bind a key to call it manually in your helix/init.scm or config.toml
(provide refresh-modeline)
```

supports very basic emacs and vim modelines with some caveats:

example modelines:
```py
# vim:ts=4 ft=py
```
```py
# ex:ts=4:ft=py:et
```
```py
# -*- mode: py; tab-width: 4; indent-tabs-mode: nil -*-
```

supported modeline fields:

`et`, `expandtab`: use spaces for indent

`noet`, `noexpandtab`: use tabs for indent (tab width not supported)

`tab-width`, `ts`, `tabstop`, `sw`, `shiftwidth`, `sts`, `softtabstop`: tab width (only affects spaces)

`language`, `mode`, `ft`, `filetype`: language/syntax highlighting, only some filetype aliases are supported and may vary

`indent-tabs-mode`: can either be `nil` (spaces) or `t` (tabs)
