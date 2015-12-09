#lang racket
(require "datadefinitions.rkt")


; Player key -> Player
; 
(define (release-update-player Player key)
  (cond [(or (string=? key "a") (string=? key "d"))  (make-Player (Player-img Player)
                                          (Player-health Player)
                                          (Player-position Player)
                                          (make-posn 0
                                                     (posn-y (Player-direction Player)))
                                          (Player-Weapon Player))]
        [(or (string=? key "w") (string=? key "s")) (make-Player (Player-img Player)
                                                                 (Player-health Player)
                                                                 (Player-position Player)
                                                                 (make-posn (posn-x (Player-direction Player))
                                                                            0)
                                                                 (Player-Weapon Player))]
        [else Player]))
        
                                          
(define (release state key)
  (make-GameState (release-update-player (GameState-player state) key)
                  (GameState-Zombies state)
                  (GameState-Projectiles state)
                  (GameState-Score state)))


(provide (all-defined-out))
