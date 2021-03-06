#lang racket/base

(require racket/match
         racket/contract)

(module+ test
  (require rackunit
           (submod "..")))

(provide string-immutable/c
         path-string-immutable/c
         bytes-immutable/c
         trimmed-string-px
         Ricoeur oe \\oe DigitalRicoeur
         (contract-out
          [title<?
           (-> string-immutable/c string-immutable/c any/c)]
          [attributes-ref
           (-> (listof (list/c symbol? string?))
               symbol?
               (or/c #f string?))]
          ))

(define Ricoeur "Ricœur")
(define oe "œ")
(define \\oe #\œ)
(define DigitalRicoeur "Digital Ricœur")

(define/final-prop string-immutable/c
  (flat-named-contract
   'string-immutable/c
   (and/c string? immutable?)))

(define/final-prop path-string-immutable/c
  (flat-named-contract
   'path-string-immutable/c
   (or/c path? (and/c string-immutable/c
                      path-string?))))

(define/final-prop bytes-immutable/c
  (flat-named-contract
   'bytes-immutable/c
   (and/c bytes? immutable?)))

(define/final-prop trimmed-string-px
  ;; n.b. as of Racket 7.4,
  ;; \S matches anything except space, tab, newline, formfeed, or return.
  ;; TODO: add tests
  ;; Is there non-ascii whitespace we need to think about ?
  #px"^(?:\\S|\\S.*\\S)$")

(define (attributes-ref attrs k)
  (define rslt
    (assq k attrs))
  (and rslt (cadr rslt)))

(define (title<? a b)
  (string-ci<? (normalize-title a) (normalize-title b)))

(define normalize-title
  (match-lambda
    ;; see note on trimmed-string-px
    ;; TODO: French - or just wait for the bibliographic database?
    [(pregexp #px"^(?i:an?|the)\\s+(\\S.*)$" (list _ trimmed))
     ;; N.B.: If this were exported, should use string->immutable-string
     trimmed]
    [full full]))

(module+ test
  (check-equal? (normalize-title "The Rain in Spain")
                "Rain in Spain"
                "normalize-title: remove \"The\"")
  (check-equal? (normalize-title "A Night to Remember")
                "Night to Remember"
                "normalize-title: remove \"A\"")
  (check-equal? (normalize-title "An Old Book")
                "Old Book"
                "normalize-title: remove \"An\"")
  (check-equal? (normalize-title "Journals")
                "Journals"
                "normalize-title: preserve normal titles")
  (check-equal? (normalize-title "The      ")
                "The      "
                "normalize-title: don't produce empty strings")
  (check-equal? (normalize-title "Theories")
                "Theories"
                "normalize-title: require word break")
  (check-equal? (normalize-title "Another Day")
                "Another Day"
                "normalize-title: require word break"))
  


