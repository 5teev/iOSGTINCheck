
import Foundation

extension String {
    func isValidGTIN() -> Bool {
        return checkGTIN(self)
    }
}

func checkGTIN(_ gtin: String) -> Bool {
    // make sure gtin has a valid length
    guard lengthIsValid(for: gtin) else { return false }

    // make sure GTIN string has only integers
    guard onlyIntegers(in: gtin) else { return false }

    // convert [Char] to [Int]
    let gtinDigitsArray = integerArray(from: gtin)

    // make sure we get all digits from the string
    guard gtinDigitsArray.count == gtin.count else { return false }

    // at this point `gtin` has been successfully converted to digits
    let (checkSum, checkDigit) = getCheckSumAndDigitForDigitsArray(gtinDigitsArray)

    // checkSum + checkDigit should be a multiple of 10
    let validationSum = (checkSum + checkDigit)
    let validationSumMod10 =  validationSum % 10 // should be 0
    let isValid = (validationSumMod10 == 0)
    return isValid
}

func lengthIsValid(for gtin: String) -> Bool {
    let validLengths = [14, 13, 12, 8]
    return validLengths.contains(gtin.count)
}

func onlyIntegers(in gtin: String) -> Bool {
    let validChars = Array("0123456789")
    let containsOnlyIntegers = gtin.allSatisfy { (char) -> Bool in
        validChars.contains(char)
    }
    return containsOnlyIntegers
}

func integerArray(from gtin: String) -> [Int] {
    let stringArray = Array(gtin)
    return stringArray.compactMap { Int(String($0)) }
}




func getCheckSumAndDigitForDigitsArray(_ gtinDigitsArray: [Int]) -> (checkSum: Int, checkDigit: Int ) {
    // the rules for this algorithm are as follows:
    // the last digit is a "check digit" to be reserved until the end, so pull it from the array immediately
    // the rest of the digits should be multiplied by 3 or 1, alternating, starting from the new final digit
    // and working back to the first digit
    // e.g., "91827364" will reserve "4" as the check digit, then sum
    // 6 * 3 + 3 * 1 + 7 * 3 + 2 * 1 + 8 * 3 + 1 * 1 + 9 * 3
    // We reverse each array so we can work back to front in this way.
    // We also use zip() to create a combination of two arrays with the same count as the shorter array,
    // so we don't have to worry about keeping track of the index as we iterate over multipliers;
    // unused factors are simply discarded.
    
    // The factors defined by the validation algorithm:
    var multipliers = [3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3]

    // make a variable of the array so...
    var gtinDigits = gtinDigitsArray
    // ...we can pop the last item from it, and work with the remainder
    guard let checkDigit = gtinDigits.popLast() else { return (0, 0) }
    
    // we will iterate over this remaining array "back to front"
    gtinDigits = gtinDigits.reversed()

    // reversing this array is formally correct, but meaningless, as the array is symmetric
    multipliers = multipliers.reversed()

    // use zip() to pair up GTIN digits with corresponding factors,
    // multiply the digits and their factors using .map(*),
    // and finally add up the array using .reduce(0, +) (i.e., add each product to 0)
    let checkSum = zip(multipliers, gtinDigits).map(*).reduce(0, +)

    // return the checkSum and the checkDigit obtained earlier
    return (checkSum, checkDigit)
}

