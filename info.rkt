#lang info

(define pkg-name "ricoeur-kernel")
(define collection "ricoeur")
(define pkg-desc
  "A \"standard library\" for Digital Ricoeur")
(define version "0.0.2")
(define pkg-authors '(philip))

(define scribblings
  '())

(define deps
  '(["base" #:version "7.4"]
    ["adjutor" #:version "0.3"]
    "reprovide-lang"
    "gregor"
    "functional-lib"))

(define build-deps
  '("scribble-lib"
    "racket-doc"
    "rackunit-lib"))
