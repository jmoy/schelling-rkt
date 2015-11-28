#lang racket
;; Simulate Schelling's segregation model
;; as described on Sargent and Stachurski's site
;; http://quant-econ.net/py/schelling.html

;; (c) Jyotirmoy Bhattacharya, http://www.jyotirmoy.net
;; LICENSE: GPL

(require plot)

(define NAGENTS 250) ; No of agents of each type
(define NNCNT 10)    ; Nearest neighbour to consider

;; Positions are vectors of two reals
;; The following functions provide an abstract interface

(define (posn x y)
  (vector x y))

(define (posn-x pos)
  (vector-ref pos 0))

(define (posn-y pos)
  (vector-ref pos 1))

;; Pythagorean distance (squared)
(define (pydist p1 p2)
  (+
   (sqr (- (posn-x p1) (posn-x p2)))
   (sqr (- (posn-y p1) (posn-y p2)))))

;; Agents have a color and a position
(struct agent (color posn))

;; Create an agent of a specified
;; color at a random position on the unit square
(define (random-agent col)
  (agent col (posn (random) (random))))

;; Main function
;; Start with an initial random state and iterate
;; as per the model. For each iteration print
;; the number of agents who move.
;; Stop and display the configuration if we reach
;; a configuration from which there are no moves.
(define (main)
  (let loop ([s (init-state)])
    (let-values ([(m ns) (next-state s)])
      (if (zero? m)
          (plot (render-state s))
          (begin
            (displayln m)
            (loop ns))))))
      
;; Create initial state with randomly
;; positioned agents
(define (init-state)
  (for*/list ([col '(orange green)]
              [_ (in-range 1 NAGENTS)])
    (random-agent col)))

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
  (define nsimilar
    (count
     (λ (a) (eq? (agent-color a) (agent-color ag)))
     neighs))
  (> nsimilar (/ NNCNT 2)))

;; Move an agent 'ag' to a new random position
;; Repeat if position is not a happy one give
;; 'state'
(define (move ag state)
  (define nag (random-agent (agent-color ag)))
  (if (happy? nag state)
      nag
      (move ag state)))

;; Return the NNCNT nearest neighbours of 'ag'
;; the state 'state'
(define (nn ag state)
  (define (dist ag2)
    (pydist (agent-posn ag) (agent-posn ag2)))
  (take
   (drop (sort state < #:key dist) 1)
   NNCNT))

;; Use the 'plot' library facilities to render
;; a scatterplot representing a state
(define (render-state state)
  (define (cmap ty)
    (case ty
      [(orange) "orange"]
      [(green) "green"]))
  (for/list ([ag state])
    (points (list (agent-posn ag))
            #:sym 'fullcircle
            #:alpha 0.6
            #:color (cmap (agent-color ag)))))

(module* main #f
  (plot-new-window? #t)
  (main))
