#lang racket/base

(require racket/file
         racket/contract)

(module+ test
  (require rackunit
           (submod "..")))

(provide (contract-out
          [call-with-output-file/unless-exn
              (->* [path-string?
                    (-> any/c any)]
                   [#:mode (or/c 'binary 'text)
                    #:exists (or/c 'error 'replace 'truncate/replace)]
                   any)]
          [with-output-to-file/unless-exn
              (->* {path-string?
                    (-> any)}
                   {#:mode (or/c 'binary 'text)
                    #:exists (or/c 'error 'replace 'truncate/replace)}
                   any)]
          ))

;; TODO: test #:exists 'error

(define (call-with-output-file/unless-exn pth
          #:mode [mode-flag 'binary]	 	 
          #:exists [exists-flag 'error]
          proc)
  (case exists-flag
    [(replace truncate/replace)
     (call-with-atomic-output-file pth
       (λ (out buffer-path)
         (case mode-flag
           [(binary)
            (proc out)]
           [else
            (close-output-port out)
            (call-with-output-file* buffer-path
              #:mode 'text
              #:exists 'truncate
              proc)])))]
    [else
     (define ok? #f)
     (define buffer (make-temporary-file))
     (dynamic-wind
      void
      (λ ()
        (call-with-output-file* buffer
          #:mode mode-flag
          #:exists 'truncate/replace ;; ok to replace buffer
          proc)
        (rename-file-or-directory buffer pth #f) ;; fail if pth exists
        (set! ok? #t))
      (λ ()
        (unless ok?
          (with-handlers ([exn:fail:filesystem? void])
            (delete-file buffer)))))]))

(define (with-output-to-file/unless-exn pth
          #:mode [mode-flag 'binary]	 	 
          #:exists [exists-flag 'error]
          thunk)
 (call-with-output-file/unless-exn pth
   #:mode mode-flag
   #:exists exists-flag
   (λ (out)
     (parameterize ([current-output-port out])
       (thunk)))))


(module+ test
  (define (do-with-output-to-file-tests pth mode)
    (with-check-info (['|#:mode argument| mode])
      (check-not-exn
       (λ ()
         (with-output-to-file pth
           #:exists 'truncate/replace
           #:mode mode
           (λ () (write 'orig))))
       "should be able to write to pth normally")

      (check-exn #rx"example"
                 (λ ()
                   (with-output-to-file/unless-exn pth
                     #:mode mode
                     #:exists 'replace
                     (λ () (error 'example))))
                 "should raise exn:fail of 'example")

      (check-eq? (file->value pth)
                 'orig
                 "orig value should still be in file")

      (check-eq? (with-output-to-file/unless-exn pth
                   #:mode mode
                   #:exists 'truncate/replace
                   (λ () (write 'new) 'done))
                 'done
                 "should write new value without exn and return 'done")

      (check-eq? (file->value pth)
                 'new
                 "new value should be in file")))
  
  (define pth
    (make-temporary-file))
  
  (dynamic-wind
   void
   (λ () 
     (test-case
      "with-output-to-file/unless-exn"
      (do-with-output-to-file-tests pth 'binary)
      (do-with-output-to-file-tests pth 'text)))
   (λ () (delete-file pth))))

