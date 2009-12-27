#-(or ccl clisp ecl sbcl) (error "This lisp implementation is not supported.")

(require :asdf)
(load "stumpwm.asd")
(asdf:oos 'asdf:load-op :stumpwm)

#+sbcl
(sb-ext:save-lisp-and-die "stumpwm"
                          :toplevel (lambda ()
                                      ;; asdf requires sbcl_home to be set, so set it to the value when the image was built
                                      (sb-posix:putenv (format nil "SBCL_HOME=~A" #.(sb-ext:posix-getenv "SBCL_HOME")))
                                      (stumpwm:stumpwm)
                                      0)
                          :executable t)

#+clisp
(ext:saveinitmem "stumpwm"
                 :init-function (lambda ()
                                  (stumpwm:stumpwm)
                                  (ext:quit))
                 :executable t :keep-global-handlers t
                 :documentation "The StumpWM Executable")

#+ccl
(ccl:save-application "stumpwm"
                      :prepend-kernel t
                      :toplevel-function #'stumpwm:stumpwm))

#+ecl
(progn
  (asdf:make-build 'stumpwm
                   :type :program
                   :monolithic t
                   :move-here t
                   :epilogue-code '(progn
                                    (funcall (intern "STUMPWM" (find-package "STUMPWM")))
                                    0))
  (when (probe-file "stumpwm-mono")
    (when (probe-file "stumpwm") (delete-file "stumpwm"))
    (rename-file "stumpwm-mono" "stumpwm")))
