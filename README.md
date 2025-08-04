# modeline.hx
Helix Plugin for modeline

# Installation
Currently, you need to use a custom branch in order to have access to regex matching on ropes from steel, building and installing helix from a custom branch (not the original plugin PR):
```sh
git clone https://github.com/gerblesh/helix.git -b line-number-config
```

then build/install the helix fork with:
```sh
cargo xtask steel
```

to install the plugin with forge:
```sh
forge pkg install --git https://github.com/gerblesh/modeline.hx.git
```

add the lines to your scm file to configure the modeline

```scheme
(require "modeline/modeline.scm")

;; register the modeline to automatically run on save/open
(modeline-enable)

;; this steel function refreshes the modeline, you can bind a key to call it manually in your helix/init.scm or config.toml
(refresh-modeline)
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
