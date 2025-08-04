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


supported modeline fields:
et, expand-tab: use spaces for indent
noet, no-expand-tab: use tabs for indent (tab width not supported)
tab-width, sw, ts, shiftwidth: tab width (only affects spaces)
language, mode, ft, filetype: language/syntax highlighting, only some filetype aliases are supported and may vary
indent-tabs-mode: can either be "nil" (spaces) or "t" (tabs)

example modelines:
```py
# vim: set ts=4 sw=4 et: ft=py
```

```py
# -*- mode: py; tab-width: 4; indent-tabs-mode: nil -*-
```
