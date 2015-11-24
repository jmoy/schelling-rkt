#lang racket
;; Simulate Schelling's segregation model
;; as described on Sargent and Stachursky's site
;; http://quant-econ.net/py/schelling.html

;; (c) Jyotirmoy Bhattacharya, http://www.jyotirmoy.net
;; LICENSE: GPL

(require plot)

(define NAGENTS 250) ; No of agents of each type
(define NNCNT 10)    ; Nearest neighbour to consider

;; Each agent is a (color . position) pair
;; with position a 2-element coordinate vector
;; The following functions provide an abstract interface

(define (mk-pos x y)
  (vector x y))

(define (get-x pos)
  (vector-ref pos 0))

(define (get-y pos)
  (vector-ref pos 1))

;; Pythagorean distance
(define (pydist p1 p2)
  (sqrt
   (+
    (expt (- (get-x p1) (get-x p2)) 2)
    (expt (- (get-y p1) (get-y p2)) 2))))

(define (mk-ag col pos)
  (cons col pos))

(define (ag-color ag)
  (car ag))

(define (ag-pos ag)
  (cdr ag))

;; Create an agent of a specified
;; color at a random position on the unit square
(define (mk-ran-ag col)
  (mk-ag col (mk-pos (random) (random))))

;; Main function
;; Start with an initial random state and iterate
;; as per the model. For each iteration print
;; the number of agents who move.
;; Stop and display the configuration if the number
;; of agents who move is less than 1/100 of NAGENTS
(define (main)
  (define (go s)
    (let-values ([(m ns) (next-state s)])
      (if (<= m (/ NAGENTS 100))
          (plot (render-state s))
          (begin
            (displayln m)
            (go ns)))))
  (go (init-state)))
      
;; Create initial state with randomly
;; positioned agents
(define (init-state)
  (for*/list ([col '(orange green)]
              [i (range 1 NAGENTS)])
    (mk-ran-ag col)))

;; One iteration
;; Returns (number of moves, new state)
(define (next-state state)
  (define nmoves 0)
  (define newstate
    (for/list ([ag state])
      (if (happy? ag state)
          ag
          (begin
            (set! nmoves (add1 nmoves))
            (move ag state)))))
  (values nmoves newstate))

;; Is the agent 'ag' happy in 'state'?
(define (happy? ag state)
  (define neighs (nn ag state))
  (define maxcnt (max-freq (map ag-color neighs)))
  (> maxcnt (/ NNCNT 2)))

;; Move an agent 'ag' to a new random position
;; Repeat if position is not a happy one give
;; 'state'
(define (move ag state)
  (define nag (mk-ran-ag (ag-color ag)))
  (if (happy? nag state)
      nag
      (move ag state)))

;; Return the NNCNT nearest neighbours of 'ag'
;; the state 'state'
(define (nn ag state)
  (define (dist ag2)
    (pydist (ag-pos ag) (ag-pos ag2)))
  (take
   (drop (sort state < #:key dist) 1)
   NNCNT))

;; Given a sequence 'xs' returns the
;; frequency of most common value
(define (max-freq xs)
  (define ht (make-hash))
  (for ([x xs]) (hash-update! ht x add1 0))
  (apply max (hash-values ht)))

;; Use the 'plot' library facilities to render
;; a scatterplot representing a state
(define (render-state state)
  (define (points-with-col ags col)
    (points (map ag-pos ags)
            #:color col))
  (let-values ([(or gr)
               (partition
                (lambda (a) (eq? 'orange (ag-color a)))
                state)])
    (list
     (points-with-col or "orange")
     (points-with-col gr "green"))))

(module* main #f
  (plot-new-window? #t)
  (main))
