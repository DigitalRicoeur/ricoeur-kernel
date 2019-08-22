#lang racket/base

(require racket/match
         (prefix-in : json))

(provide jsexpr?
         write-json
         read-json
         jsexpr->string
         jsexpr->bytes
         string->jsexpr
         bytes->jsexpr)

(define memo
  (make-weak-hasheq))

(define (remember x ret)
  (hash-set! memo x ret)
  ret)

(define (jsexpr? x)
  (or (exact-integer? x)
      (and (inexact-real? x)
           (rational? x))
      (boolean? x)
      (string? x)
      (eq? x 'null)
      (match (hash-ref memo x '???)
        ['???
         (cond
           [(list? x)
            (remember x (andmap jsexpr? x))]
           [(hash? x)
             (remember x (for/and ([(k v) (in-hash x)])
                           (and (symbol? k) (jsexpr? v))))]
           [else
            #f])]
        [answer
         answer])))

(define (write-json js [out (current-output-port)]
                    #:encode [enc 'control])
  (:write-json js out #:encode enc #:null 'null))

(define (read-json [in (current-input-port)])
  (:read-json in #:null 'null))

(define (jsexpr->string js #:encode [enc 'control])
  (:jsexpr->string js #:encode enc #:null 'null))

(define (jsexpr->bytes js #:encode [enc 'control])
  (:jsexpr->bytes js #:encode enc #:null 'null))

(define (string->jsexpr v)
  (:string->jsexpr v #:null 'null))

(define (bytes->jsexpr v)
  (:bytes->jsexpr v #:null 'null))
