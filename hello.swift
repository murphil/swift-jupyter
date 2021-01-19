import TensorFlow

let x = Tensor<Float>([40])
let y = Tensor<Float>([2])

let w = x + y

print(w)

import PythonKit

let random = Python.import("random")
print(random.random())
