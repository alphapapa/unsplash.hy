#!/usr/bin/env hy

(import [datetime [datetime :as dt
                   timedelta]]
        [glob [glob]]
        [time [mktime]]
        os requests)

(defun datetime-to-timestamp (d)
  (mktime (.timetuple d)))

(def *download-dir* (os.path.expanduser "~/.cache/unsplash"))
(def *output-file* (os.path.join *download-dir* "latest.jpg"))
;;  (def *random-url* "https://source.unsplash.com/random")
;;  (def *random-url* "https://source.unsplash.com/category/nature")
(def *random-url* "https://unsplash.it/1920/1080?random")

(assert (os.path.isdir *download-dir*) (+ "Directory doesn't exist: " *download-dir*))

;; Rename existing file
(when (os.path.exists *output-file*)
  (os.rename *output-file*
             (os.path.join *download-dir* (+ (str (os.path.getmtime *output-file*)) ".jpg"))))

;; Download file to disk
(let ((r (requests.get *random-url*)))
  (assert r.ok (+ "Request failed: " (str r.status-code)))
  (with [[f (open *output-file* "wb")]]
        (.write f r.content)))

;; Delete old wallpapers
(let ((oldest-ts (datetime-to-timestamp (- (dt.now) (timedelta :days 30)))))
  (for [file (glob (os.path.join *download-dir* "*.jpg"))]
    (let ((file-mtime (os.path.getmtime file)))
      (when (< file-mtime oldest-ts)
        (print (+ file " is older than 30 days: " (str file-mtime) " < " (str oldest-ts) ", would delete"))))))
