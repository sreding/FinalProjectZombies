#lang racket

(require 2htdp/image)

; Player:
; img - Number - this number corresponds to an image
; health - integer - the players health
; position - posn - the players position
; direction - is one of (1,0), (0,1), (-1,0), (0,-1), (0,0)
(define-struct Player [img health position direction Weapon] #:prefab)

; Weapon
; img - Number - Number corresponds to an image
; x - Number - x-cordinate of the mouse pointer 
; y - Number - y-cordinate of the mouse pointer 
; projectilespeed - Number - projectilespeed
(define-struct Weapon [img x y projectilespeed]  #:prefab)

; Projectile
; img - Image - Number corresponds to an image
; position - posn - position of the projectile
; direction - posn - direction of the projectile
(define-struct Projectile [img position direction damage]  #:prefab)

; Zombie
; img - Image - one of: ZOMBIE1 (normal), ZOMBIE2 (super-zombie)
; health - Number - the Zombies health
; position - posn - the Zombies position
; damage - Number - the Zombies damage
(define-struct Zombie [img health position damage]  #:prefab)

; Powerup
; position - posn - position of the PowerUp
; nr - Number - is one of: 0 (health pack), 1 (nuke)
(define-struct PowerUp [position nr] #:prefab)


; Game State
; player- Player
; Zombies - List<Zombie>
; Projectiles - List<Projectile>
; PowerUps - List<PowerUp>
; Score - Integer
; 1 -> Menu
; 2 -> HowTo
; 3 -> HowTo2
; 4 -> Game Over
; 5 -> Level1
; 10 -> pause the game
(define-struct GameState [player Zombies Projectiles PowerUps Score Menue] #:prefab)



; there is no posn in racket, so we did it ourself
(define-struct posn [x y] #:prefab)





; posn -> posn
; Normalize vector
(define (normalise vec)
  (cond [(= 0 (posn-x vec) (posn-y vec)) (make-posn 0 0)]
        [else
         (make-posn  (/ (posn-x vec) (sqrt (+ (sqr (posn-x vec)) (sqr (posn-y vec)))))
                     (/ (posn-y vec) (sqrt (+ (sqr (posn-x vec)) (sqr (posn-y vec))))))]))

; global constants
(define BACKGROUND (bitmap/file "images/Map.png"))
(define SPEED 10)
(define HEIGHT (image-height BACKGROUND))
(define WIDTH (image-width BACKGROUND))
(define ZOMBIE1 (rotate 90 (bitmap/file "images/Zombie.png")))
(define ZOMBIE2 (rotate 90 (bitmap/file "images/Super-Zombie.png")))
(define HEALTH (bitmap/file "images/MedPU.png"))
(define NUKE (bitmap/file "images/NukePU.png"))
(define Menue (bitmap/file "images/Menu.png"))
(define HowTo (bitmap/file "images/HowTo.png"))
(define HowToTwo (bitmap/file "images/HowToTwo.png"))
(define GameOver (bitmap/file "images/GameOver.png"))
(define GUN (rotate 90 (bitmap/file "images/Gun.png")))

;Initial State Menue
(define InitState (make-GameState (make-Player 1
                                             100
                                             ;(make-posn (/ WIDTH 2) (/ (- HEIGHT 30)2))
                                             (make-posn 100 100)
                                             (make-posn 0 0)
                                             (make-Weapon 1
                                                          0
                                                          0
                                                          500))
                                (list)
                                '()
                                '()
                                0
                                1))
;HowTo 1
(define HowTo-state (make-GameState (make-Player 1
                                             100
                                             ;(make-posn (/ WIDTH 2) (/ (- HEIGHT 30)2))
                                             (make-posn 100 100)
                                             (make-posn 0 0)
                                             (make-Weapon 1
                                                          0
                                                          0
                                                          500))
                                (list)
                                '()
                                '()
                                0
                                2))
;HowTo 2
(define HowTo2-state (make-GameState (make-Player 1
                                             100
                                             ;(make-posn (/ WIDTH 2) (/ (- HEIGHT 30)2))
                                             (make-posn 100 100)
                                             (make-posn 0 0)
                                             (make-Weapon 1
                                                          0
                                                          0
                                                          500))
                                (list)
                                '()
                                '()
                                0
                                3))

;Initial State
(define Level1 (make-GameState (make-Player 1
                                             100
                                             ;(make-posn (/ WIDTH 2) (/ (- HEIGHT 30)2))
                                             (make-posn 100 100)
                                             (make-posn 0 0)
                                             (make-Weapon 1
                                                          0
                                                          0
                                                          500))
                                (list)
                                '()
                                '()
                                0
                                5))





; global functions:
; Number Number Number -> Boolean
; returns true if player hits an obstacle
; (we added level in case we wanted to another level, but we ended up not doing it,
; but we left it in there in case we want to do it in the future)
(define (obstacle-hit x y level)
  (cond [(= level 1) (or
                      (and (< 535 x 840) ; House, Center
                           (< 395 y 670))
                     (and (< 37 x 330) ; House, bottom left
                           (< 405 y 663))
                     (and (< 383 x 768) ; House, Top center
                           (< -30 y 261))
                     (and (< 1173 x 1309) ; House, Top right
                           (< 30 y 300))
                     (and (< 263 x 400) ;Blue Car
                           (< 672 y 737))
                     (and (< 415 x 636) ;Truck
                           (< 750 y 890))
                     (and (< 860 x 946) ;Red Car
                           (< 0 y 109))
                     (and (< 1060 x 1165) ;Police car
                           (< 385 y 560))
                      (< x 30)
                      (< (- WIDTH 30) x)
                      (< y 30)
                      (< (- HEIGHT 40) y))]))

; global functions
; Zombie Number Number -> Boolean
;same as obsatcle-hit but changed hitboxes for Zombies
(define (obstacle-hit-z x y level)
  (cond [(= level 1) (or
                      (and (< 535 x 840) ; House, Center
                           (< 395 y 670))
                     (and (< 37 x 330) ; House, bottom left
                           (< 405 y 663))
                     (and (< 383 x 768) ; House, Top center
                           (< -30 y 261))
                     (and (< 1173 x 1309) ; House, Top right
                           (< 30 y 300))
                     (and (< 263 x 400) ;Blue Car
                           (< 672 y 737))
                     (and (< 415 x 636) ;Truck
                           (< 750 y 890))
                     (and (< 860 x 946) ;Red Car
                           (< 0 y 109))
                     (and (< 1060 x 1165) ;Police car
                           (< 385 y 560))
                     )]))

; Number Number Number -> Boolean
; same as obsatcle-hit but changed hitboxes for projectiles
(define (obstacle-hit-proj x y level)
  (cond [(= level 1) (or
                      (and (< 555 x 815) ; middle house
                           (< 420 y 645))
                     (and (< 55 x 305)
                           (< 420 y 640))
                     (and (< 410 x 750) ; top house 
                           (< 0 y 240))
                     (and (< 1200 x 1280) ; right house
                           (< 45 y 275))
                     
                      (< x 0)
                      (< (- WIDTH 00) x)
                      (< y 0)
                      (< (- HEIGHT 0) y))]))

(provide (all-defined-out))
