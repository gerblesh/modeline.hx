;; unfortunately, setting the tab-width and using the \t character is not currently supported (requires a patch to allow a cmd to set the tab character width)
;; This *already* requires a patch that adds rope->match-regexp
;; -*- language: scm; tab-width: 2; indent-tabs-mode: nil -*-

(require-builtin helix/core/text)
(require (prefix-in helix. "helix/commands.scm"))
(require "helix/editor.scm")

(define lang-aliases
  (hash "js"
        "javascript"
        "ts"
        "typescript"
        "sh"
        "bash"
        "rb"
        "ruby"
        "py"
        "python"
        "c++"
        "cpp"
        "cxx"
        "cpp"
        "h"
        "c"
        "hpp"
        "cpp"
        "el"
        "elisp"
        "rkt"
        "racket"
        "scm"
        "scheme"
        "md"
        "markdown"
        "txt"
        "text"
        "yml"
        "yaml"
        "rs"
        "rust"))

(define emacs-modeline-regex "-\\*-\\s*(.+?)\\s*-\\*-")
(define vim-modeline-regex "(?i)(?:vi|vim):.*?((?:set)?\\s+[^:]*).*")

(define (split-whitespace s)
  (rope->match-regexp (string->rope s) "[^\\s;:.,()\\[\\]{}=]+"))

(define (test)
  (rope->match-regexp
   (string->rope
    ";; unfortunately, setting the tab-width and using the \t character is not currently supported (requires a patch to allow a cmd to set the tab character width)
")
   emacs-modeline-regex))

(define (check-modeline line)
  (define (match-and-split regex)
    (let ([m (try-list-ref (rope->match-regexp line regex) 0)]) (split-whitespace m)))
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
  (register-hook! 'document-saved modeline))

(define (get-current-doc-id)
  (let* ([focus (editor-focus)]) (editor->doc-id focus)))

(define (modeline doc-id)
  (let ([t (editor->text doc-id)]) (search-modelines t)))

(define (refresh-modeline)
  (modeline (get-current-doc-id)))

(define (normalize-lang s)
  (or (hash-try-get lang-aliases s) s))

;; common keys used in emacs and vim modelines:
(define tabs-mode (hash "nil" #f "t" "t"))
(define language-keys (hashset "mode" "language" "ft" "filetype"))
(define width-keys (hashset "tab-width" "sw" "ts" "shiftwidth"))
(define tab-keys (hashset "noet" "no-expand-tab"))
(define expand-tab-keys (hashset "et" "expand-tab"))

(define (apply-modeline lst)
  (let loop ([i 0]
             [indent #f])
    (when (< i (length lst))
      (when indent
        (helix.indent-style indent))
      (let* ([current (try-list-ref lst i)]
             [next (try-list-ref lst (+ i 1))])
        (cond
          [(and next (hashset-contains? language-keys current))
           (begin
             (helix.set-language (normalize-lang next))
             (loop (+ i 2) indent))]
          [(and next (hashset-contains? width-keys current) (string->number next) (bool? indent))
           (loop (+ i 2) next)]
          [(and (not indent) (hashset-contains? expand-tab-keys current)) (loop (+ i 1) "2")]
          [(hashset-contains? tab-keys current) (loop (+ i 1) "t")]
          [(and (string=? current "indent-tabs-mode") next)
           (loop (+ i 2) (let ([m (hash-ref tabs-mode next)]) (if m m indent)))]
          [else (loop (+ i 1) indent)])))))

(provide modeline-enable
         refresh-modeline)
