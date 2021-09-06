import Foundation

let numberFormatter: NumberFormatter = {
    let nf = NumberFormatter()
    nf.locale = Locale(identifier: "en_US_POSIX")
    nf.decimalSeparator = "."
    return nf
}()
