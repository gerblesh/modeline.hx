;; unfortunately, setting the tab-width and using the \t character is not currently supported (requires a patch to allow a cmd to set the tab character width)
;; -*- mode: steel; tab-width: 2; indent-tabs-mode: nil -*-
;

(require-builtin helix/core/text)
(require (prefix-in helix. "helix/commands.scm"))
(require "helix/editor.scm")

;; hashmap of file extensions/filetypes that may be used in modelines, could be ditched if: https://github.com/helix-editor/helix/pull/13085 is merged
(define lang-aliases
  ;; JavaScript / TypeScript
  (hash "js"
        "javascript"
        "ts"
        "typescript"
        ;; Shell
        "sh"
        "bash"
        ;; Ruby
        "rb"
        "ruby"
        ;; Python
        "py"
        "python"
        ;; C / C++
        "c++"
        "cpp"
        "cxx"
        "cpp"
        "hpp"
        "cpp"
        "h"
        "c"
        ;; Lisp-family
        "steel"
        "scheme"
        "el"
        "elisp"
        "scm"
        "scheme"
        "rkt"
        "racket"
        "fnl"
        "fennel"
        "clj"
        "clojure"
        "cljs"
        "clojure"
        ;; Markdown / Text
        "md"
        "markdown"
        "txt"
        "text"
        ;; YAML
        "yml"
        "yaml"
        ;; Rust
        "rs"
        "rust"
        ;; Julia
        "jl"
        "julia"
        ;; Perl
        "pl"
        "perl"
        ;; Kotlin
        "kt"
        "kotlin"
        ;; Haskell
        "hs"
        "haskell"
        ;; F#
        "f#"
        "fsharp"
        "f-sharp"
        "fsharp"
        "fs"
        "fsharp"
        ;; C#
        "cs"
        "c-sharp"
        "c#"
        "c-sharp"
        "csharp"
        "c-sharp"
        ;; PowerShell
        "ps1"
        "powershell"
        ;; LaTeX
        "tex"
        "latex"
        ;; MATLAB / Octave
        "m"
        "matlab"
        ;; Batch
        "bat"
        "batch"
        ;; Elixir
        "ex"
        "elixir"
        "exs"
        "elixir"
        ;; Erlang
        "erl"
        "erlang"
        "hrl"
        "erlang"
        ;; Systemd files
        "service"
        "systemd"
        "mount"
        "systemd"
        "timer"
        "systemd"
        "socket"
        "systemd"
        ;; Typst
        "typ"
        "typst"
        ;; Ini aliases
        "cfg"
        "ini"
        "conf"
        "ini"
        ; Ocaml
        "ml"
        "ocaml"
        "mli"
        "ocaml-interface"))

(define emacs-modeline-regex (rope-regex "-\\*-\\s*(.+?)\\s*-\\*-"))
(define vim-modeline-regex (rope-regex "(?i)(vi|vim|ex):.*?((set)?\\s+[^:]*).*"))
(define whitespace-regex (rope-regex "[\\s;:.,()\\[\\]{}=]+"))

(define (split-whitespace r)
  (rope-regex-split whitespace-regex r))

(define (check-modeline line)
  (define (match-and-split regex)
    (let ([m (rope-regex-find regex line)])
      (if m
          (split-whitespace m)
          #f)))
  (or (match-and-split vim-modeline-regex) (match-and-split emacs-modeline-regex)))

(define (search-modelines t)
  (let* ([line-count (rope-len-lines t)]
         [max-lines (min 5 line-count)]
         [check-lines (lambda (start count)
                        (let loop ([i start])
                          (if (< i (+ start count))
                              (let* ([line (rope->line t i)]
                                     [parsed (check-modeline line)])
                                (if parsed
                                    (begin
                                      (apply-modeline parsed)
                                      parsed)
                                    (loop (+ i 1))))
                              #f)))])
    (or (check-lines 0 max-lines) (check-lines (- line-count max-lines) max-lines))))

(define (modeline-enable)
  (register-hook! 'document-opened modeline)
  (register-hook! 'document-saved modeline)
  (refresh-modeline))

(define (get-current-doc-id)
  (let* ([focus (editor-focus)]) (editor->doc-id focus)))

(define (modeline doc-id)
  (let ([t (editor->text doc-id)]) (search-modelines t)))

(define (refresh-modeline)
  (modeline (get-current-doc-id)))

(define (normalize-lang s)
  (let ([lower (string->lower s)]) (or (hash-try-get lang-aliases lower) lower)))

;; common keys used in emacs and vim modelines:
(define tabs-mode (hash "t" "t"))
(define language-keys (hashset "mode" "language" "ft" "filetype"))
(define width-keys (hashset "tab-width" "sw" "shiftwidth" "ts" "tabstop" "sts" "softtabstop"))
(define tab-keys (hashset "noet" "noexpandtab"))
(define expand-tab-keys (hashset "et" "expandtab"))

(define (try-convert-rope r)
  (if (Rope? r)
      (rope->string r)
      #f))

(define (apply-modeline lst)
  (let loop ([i 0]
             [indent #f])
    (when (< i (length lst))
      (let* ([current (try-convert-rope (try-list-ref lst i))]
             [next (try-convert-rope (try-list-ref lst (+ i 1)))])
        (cond
          [(and next (hashset-contains? language-keys current))
           (begin
             (helix.set-language (normalize-lang next))
             (loop (+ i 2) indent))]
          [(and next (hashset-contains? width-keys current) (string->number next) (bool? indent))
           (begin
             (helix.indent-style next)
             (loop (+ i 2) next))]
          [(and (not indent) (hashset-contains? expand-tab-keys current)) (loop (+ i 1) "2")]
          [(hashset-contains? tab-keys current)
           (begin
             (helix.indent-style "t")
             (loop (+ i 1) "t"))]
          [(and (string=? current "indent-tabs-mode") next)
           (loop (+ i 2) (let ([m (hash-try-get tabs-mode next)]) (if m m indent)))]
          [else (loop (+ i 1) indent)])))))

(provide modeline-enable
         refresh-modeline)
