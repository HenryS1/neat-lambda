(asdf:defsystem "neat-lambda"
  :version "0.1.0"
  :author "Henry Steere"
  :license "MIT"
  :components ((:file "package")
               (:file "lambdas"))
  :description "Provides abbreviated lambdas for Common Lisp"
  :in-order-to ((test-op (test-op "lambdas-test"))))
