#lang info

(define collection "ricoeur")
(define pkg-desc
  "A \"standard library\" for Digital Ricoeur")
(define version "0.0")
(define pkg-authors '(philip))

(define scribblings
  '())

(define deps
  '(["base" #:version "7.2"]
    "adjutor"
    "gregor"
    "functional-lib"))

(define build-deps
  '("scribble-lib"
    "racket-doc"
    "rackunit-lib"))
