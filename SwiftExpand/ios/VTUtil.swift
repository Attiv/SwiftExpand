import Foundation
class VTUtil {
  /**
   延时执行
   Delays the execution of a closure by the specified number of seconds.

   - Parameters:
     - seconds: The number of seconds to delay the execution.
     - closure: The closure to be executed after the delay.
   */
  class func delayExecution(seconds: Double, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
      closure()
    }
  }
}
