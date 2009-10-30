(defpackage #:uid-demo
  (:use :cl :sheeple :until-it-dies))
(in-package :uid-demo)

(defparameter *path-to-uid* "/home/zkat/hackery/lisp/until-it-dies/")

(defproto =uid-demo= (=engine=)
  ((title "UID Demo")
   (window-width 600)
   (window-height 600)))

(defproto =game-object= ()
  ((x 0 :accessor nil)
   (y 0 :accessor nil)
   content))

(defreply draw ((thing =game-object=) &rest args &key)
  (with-properties (x y content) thing
    (apply 'draw content :x x :y y args)))

(defreply update ((thing =game-object=) dt &rest args &key)
  (apply 'update (content thing) dt args))

(defvar *alien*
  (defobject =game-object=
      ((content (create-image (merge-pathnames "res/lisplogo_alien_256.png" *path-to-uid*)))
       visiblep (x 255) (y 356))))

(defreply draw :around ((thing *alien*) &key)
  (with-properties (visiblep) thing
    (when visiblep (call-next-reply))))

(defvar *anim*
  (defobject =game-object=
      ((content (create-animation (merge-pathnames "res/explosion.png" *path-to-uid*)
                                  15 14 0.05 14))
       (speed 300) (x 50) (y 50))))

(defreply update ((engine =uid-demo=) dt &key)
  (update *anim* dt)
  (with-properties (x y speed) *anim*
    (when (and (key-down-p :right)
               (< x (window-width engine)))
      (incf x (* speed dt)))
    (when (and (key-down-p :left)
               (< 0 x))
      (decf x (* speed dt)))
    (when (and (key-down-p :up)
               (< y (window-height engine)))
      (incf y (* speed dt)))
    (when (and (key-down-p :down)
               (< 0 y))
      (decf y (* speed dt)))))

(defreply draw ((engine =uid-demo=) &key)
  (let ((scale-factor 5))
    (with-color *green*
      (dotimes (i 1000)
        (draw-point (make-point :x (random 600)
                                :y (random 600)
                                :z 0))))
    (draw "HURR DURR HURR!" :x 60 :y 50 :x-scale scale-factor :y-scale scale-factor)
    (draw *anim* :x-scale scale-factor :y-scale scale-factor)
    (draw *alien*)))

(defreply mouse-down ((engine =uid-demo=) button click-x click-y)
  (with-properties ((alien-x x) (alien-y y) visiblep) *alien*
    (case button
      (1 (setf visiblep t
               alien-x click-x
               alien-y (- (window-height engine) click-y)))
      (3 (setf visiblep (not visiblep))))))
