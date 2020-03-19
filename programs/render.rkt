#lang racket

; Draw weapon fix

(require 2htdp/image)
(require "DataDefinitions.rkt")

; Zombies, img -> image
; Takes a List of Zombie and places it on the image
(define (draw-zombies Zombies Player Image)
  (cond [(empty? Zombies) Image]
        [else (place-image  (rotate-towards (Zombie-img (first Zombies)) (first Zombies) Player)
                            (posn-x (Zombie-position (first Zombies)))
                            (posn-y (Zombie-position (first Zombies)))
                            (draw-zombies (rest Zombies) Player Image))]))
; Projectiles --> image
; Takes a List of Projectiles and places them on the image
(define (draw-projectiles Projectiles Image)
  (cond [(empty? Projectiles) Image]
        [else (place-image (cond [(= 1 (Projectile-img (first Projectiles))) (circle 3 "solid" "red")]) 
                           (posn-x (Projectile-position (first Projectiles)))
                           (posn-y (Projectile-position (first Projectiles)))
                           (draw-projectiles (rest Projectiles) Image))]))

; rotate-towards : Image -> Image
; Takes a Zombie and rotates it towards the player
(define (rotate-towards img Zombie Player)
  (local [(define angle (+ 90 (* (/ 360 (* 2 pi))
                                 (atan
                                  (/
                                   (- (posn-y (Zombie-position Zombie)) (posn-y (Player-position Player)))
                                   (if (= 0 (-  (posn-x (Player-position Player)) (posn-x (Zombie-position Zombie)))) 1 (-  (posn-x (Player-position Player)) (posn-x (Zombie-position Zombie))))))))
            )]
    (cond
      [(> (posn-x (Player-position Player)) (posn-x (Zombie-position Zombie))) (rotate (+ 180 angle) img)]
      [(< (posn-x (Player-position Player)) (posn-x (Zombie-position Zombie))) (rotate angle img)]
      [(and (> (posn-y (Player-position Player)) (posn-y (Zombie-position Zombie)))
            (= (posn-x (Player-position Player)) (posn-x (Zombie-position Zombie))))
       (rotate 180 img)]
      [(= (posn-x (Player-position Player)) (posn-x (Zombie-position Zombie)))
       img]))) 


; Player -> Number
; retruns the angle by which the weapon needs to be rotated 
(define (WeaponAngle Player)
  (cond [(and (= (posn-x (Player-position Player)) (Weapon-x (Player-Weapon Player))) (> (posn-y (Player-position Player)) (Weapon-y (Player-Weapon Player))))  90]
        [(= (posn-x (Player-position Player)) (Weapon-x (Player-Weapon Player))) 180]
        [(not (= (posn-x (Player-position Player)) (Weapon-x (Player-Weapon Player))))
         (local ((define angle (+ 270 (* (/ 360 (* 2 pi))
                                         (atan
                                          (/
                                           (- (Weapon-y (Player-Weapon Player)) (posn-y (Player-position Player)))
                                           (-  (posn-x (Player-position Player)) (Weapon-x (Player-Weapon Player)))))))))
           (if (< (Weapon-x (Player-Weapon Player)) (posn-x (Player-position Player))) (+ angle 180) angle))] ))




; Player, Image -> Image
; Takes a Player and places him on the image
(define (draw-gun Player img)
  (place-image (rotate (WeaponAngle Player) (cond [(= 1 (Weapon-img (Player-Weapon Player))) GUN] ))
               (+ (posn-x (Player-position Player)) 0)
               (+ (posn-y (Player-position Player)) 0)
               img))

; Score, Image -> Image
; places the score on the image
(define (draw-score score img)
  (place-image
   (text (string-append "Score: " (number->string score)) 24 "red")
   (- WIDTH 90) 20
   img))

; Player, Image -> Image
; places the player health on the image
(define (draw-health Player img)
  (place-image (text (string-append "Health: " (number->string (if (< (Player-health Player) 0) 0 (Player-health Player)))) 24 "red")
               90 20
               img))

; PowerUps Image -> Image
; places the PowerUps on the image
(define (draw-power-ups PowerUps img)
  (cond [(empty? PowerUps) img]
        [else (place-image (if (= (PowerUp-nr (first PowerUps)) 0) HEALTH NUKE)
                           (posn-x (PowerUp-position (first PowerUps)))
                           (posn-y (PowerUp-position (first PowerUps)))
                           (draw-power-ups (rest PowerUps) img))]))



; GameStat -> Image
; handels all the rendering (to-draw)
(define (render state)
  (cond [(or (= (GameState-Menue state) 5)  (= (GameState-Menue state) 10))
         (if (= (GameState-Menue state) 10) (overlay (text "PAUSE" 40 "red")
                                                     (draw-health (GameState-player state)
                                                                  (draw-score (GameState-Score state)
                                                                              (draw-power-ups (GameState-PowerUps state)
                                                                                              (draw-gun (GameState-player state)
                                                                                                        (draw-projectiles
                                                                                                         (GameState-Projectiles state)
                                                                                                         (draw-zombies
                                                                                                          (GameState-Zombies state) (GameState-player state)
                                                                                                          BACKGROUND)))))))
             (draw-health (GameState-player state)
                          (draw-score (GameState-Score state)
                                      (draw-power-ups (GameState-PowerUps state)
                                                      (draw-gun (GameState-player state)
                                                                (draw-projectiles
                                                                 (GameState-Projectiles state)
                                                                 (draw-zombies
                                                                  (GameState-Zombies state) (GameState-player state)
                                                                  BACKGROUND)))))))
         ]
        [(= (GameState-Menue state) 1) Menue]
        [(= (GameState-Menue state) 2) HowTo]
        [(= (GameState-Menue state) 3) HowToTwo]
        [(= (GameState-Menue state) 4) (place-image (text (string-append "Score: " (number->string (GameState-Score state))) 40 "white") 640 350 GameOver)]))






(provide (all-defined-out))