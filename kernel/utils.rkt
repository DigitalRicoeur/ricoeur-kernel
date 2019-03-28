#lang racket/base

(require racket/match
         racket/contract
         )

(module+ test
  (require rackunit
           (submod "..")))

(provide string-immutable/c
         path-string-immutable/c
         trimmed-string-px
         (contract-out
          [title<?
           (-> string-immutable/c string-immutable/c any/c)]
          [attributes-ref
           (-> (listof (list/c symbol? string?))
               symbol?
               (or/c #f string?))]
          ))

(define/final-prop string-immutable/c
  (flat-named-contract
   'string-immutable/c
   (and/c string? immutable?)))

(define/final-prop path-string-immutable/c
  (flat-named-contract
   'path-string-immutable/c
   (or/c path? (and/c string-immutable/c
                      path-string?))))

(define/final-prop trimmed-string-px
  ;; n.b. \S only matches ASCII
  ;; TODO: add tests
  #px"^[^\\s]$|^[^\\s].*[^\\s]$")

(define (attributes-ref attrs k)
  (define rslt
    (assq k attrs))
  (and rslt (cadr rslt)))

(define (title<? a b)
  (string-ci<? (normalize-title a) (normalize-title b)))

(define normalize-title
  (match-lambda
    [(pregexp #px"^(?i:an?|the)\\s+([^\\s].*)$" (list _ trimmed))
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
  

