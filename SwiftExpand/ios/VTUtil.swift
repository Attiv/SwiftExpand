import Foundation
public class VTUtil {
  /// The HTML string meta tag for mobile devices.
  /// This meta tag sets the viewport width to the device width, disables user scaling, and prevents the page from being zoomed in or out.
  public static let mobileHtmlStringMeta = "<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0;'>"

  /**
   延时执行
   Delays the execution of a closure by the specified number of seconds.

   - Parameters:
     - seconds: The number of seconds to delay the execution.
     - closure: The closure to be executed after the delay.
   */
  public class func delayExecution(seconds: Double, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
      closure()
    }
  }

  /// Converts an HTML string to a mobile-friendly format.
  ///
  /// - Parameter htmlStr: The HTML string to be converted.
  /// - Returns: The converted mobile-friendly HTML string.
  public class func convertHtmlStringToMobile(htmlStr: String) -> String {
    var mobileHtmlString = htmlStr
    if !mobileHtmlString.contains("content='width=device-width") {
      mobileHtmlString = mobileHtmlStringMeta + mobileHtmlString
    }
    return mobileHtmlString
  }
}
