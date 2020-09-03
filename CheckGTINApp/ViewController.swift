//
//  ViewController.swift
//  CheckGTINApp
//
//  Created by Steve Milano on 8/28/20.
//  Copyright © 2020 Steve Milano. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    enum GTIN {
        case valid(gtin: String)
        case invalid(gtin: String)
    }

    @IBOutlet weak var gtinTextField: UITextField!
    @IBOutlet weak var checkDigitLabel: UILabel!
    @IBOutlet weak var checkSumLabel: UILabel!
    @IBOutlet weak var validateButton: UIButton!
    @IBOutlet weak var calculationLabel: UILabel!
    @IBOutlet weak var explanationLabel: UILabel!

    let validGTINs = [
        "76308722791248", // valid GTIN-14
        "7630872279124", // valid GTIN-13
        "763087227912", // valid GTIN-12
        "76308727" // valid GTIN-8
    ]

    let invalidGTINs = [
        "76308722791247", // GTIN-14 with wrong check key
        "7630872279123", // GTIN-13 with wrong check key
        "763087227911", // GTIN-12 with wrong check key
        "76308726", // GTIN-8 with wrong check key
        "0", // wrong length
        "abcdabcd", // right length, no integers
        "9876543a" // right length, not all integers
    ]

    var gtinsArray: [GTIN] = []
    let validColor = UIColor(red:0.07, green:0.32, blue:0.08, alpha:1.00)
    let invalidColor = UIColor(red:0.50, green:0.00, blue:0.15, alpha:1.00)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        testValidGTINs()
        testInvalidGTINs()
        createGTINsArray()
        
    }

    func createGTINsArray() {

        validGTINs.forEach { gtin in
            gtinsArray.append(.valid(gtin: gtin))
        }
        invalidGTINs.forEach { gtin in
            gtinsArray.append(.invalid(gtin: gtin))
        }
    }
    @IBAction func tapValidateButton(_ sender: UIButton) {
        let gtin: String = gtinTextField.text ?? "00000000"
        let valid: Bool = gtin.isValidGTIN()
        gtinTextField.textColor = valid ? validColor : invalidColor
        if valid {
            let (checkSum, checkDigit) = getCheckSumAndDigitForValidGTIN(gtin)
            checkDigitLabel.text = String(checkDigit)
            checkSumLabel.text = String(checkSum)
            updateCalculationLabel(gtin: gtin, checkSum: checkSum, checkDigit: checkDigit, valid: true)
        } else {
            let (checkSum, checkDigit) = getCheckSumAndDigitForAnyGTIN(gtin)
            checkDigitLabel.text = String(checkDigit)
            checkSumLabel.text = String(checkSum)
            updateCalculationLabel(gtin: gtin, checkSum: checkSum, checkDigit: checkDigit, valid: false)
        }
        checkDigitLabel.textColor = valid ? validColor : invalidColor
        checkSumLabel.textColor = valid ? validColor : invalidColor
    }

    func updateCalculationLabel(gtin: String, checkSum: Int, checkDigit: Int, valid: Bool) {
        calculationLabel.text = "\(checkSum) + \(checkDigit) = \(checkSum + checkDigit)    \(valid ? "✓⃝" : "✘")"
        calculationLabel.textColor = valid ? validColor : invalidColor
        if lengthIsValid(for: gtin), valid {
            explanationLabel.text = "Checksum plus check digit is a multiple of 10"
        } else if !lengthIsValid(for: gtin) {
            explanationLabel.text = "GTIN has the wrong length"
        } else { // not valid
            explanationLabel.text = "Checksum plus check digit isn't a multiple of 10"
        }
        explanationLabel.textColor = valid ? validColor : invalidColor
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gtinsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
        let gtin = gtinsArray[indexPath.row]
        let text: String
        let valid: Bool
        switch gtin {
        case .valid(let gtin):
            text = gtin
            valid = true
        case .invalid(let gtin):
            text = gtin
            valid = false
        }
        cell.textLabel?.text = text
        cell.textLabel?.textColor = valid ? .black : invalidColor
        return cell
    }
    
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
            loadGTIN(gtinsArray[indexPath.row])
    }

    func loadGTIN(_ gtin: GTIN) {
        let text: String
        switch gtin {
        case .valid(let gtin), .invalid(let gtin):
            text = gtin
        }
        gtinTextField.text = text
        gtinTextField.textColor = .black
    }

    func getCheckSumAndDigitForValidGTIN(_ gtin: String) -> (checkSum: Int, checkDigit: Int ) {
        let validLengths = [14, 13, 12, 8]
        guard validLengths.contains(gtin.count) else { return (0, 0) }

        // make sure GTIN string has only integers
        let validChars = Array("0123456789")
        let containsOnlyIntegers = gtin.allSatisfy { (char) -> Bool in
            validChars.contains(char)
        }
        if !containsOnlyIntegers { return (0, 0) }

        // convert [Char] to [Int]
        let gtinDigitsArray = Array(gtin).compactMap { Int(String($0)) }

        // make sure we get all digits from the string
        guard gtinDigitsArray.count == gtin.count else { return (0, 0) }

        return getCheckSumAndDigitForDigitsArray(gtinDigitsArray)
    }

    func getCheckSumAndDigitForAnyGTIN(_ gtin: String) -> (checkSum: Int, checkDigit: Int ) {
        // convert [Char] to [Int]
        let gtinDigitsArray = Array(gtin).compactMap { Int(String($0)) }
        return getCheckSumAndDigitForDigitsArray(gtinDigitsArray)
    }

    // testing
    func testValidGTINs() {
        let validGTINs = [
            "76308722791248", // valid GTIN-14
            "7630872279124", // valid GTIN-13
            "763087227912", // valid GTIN-12
            "76308727" // valid GTIN-8
        ]
        validGTINs.forEach { gtin in
            assert(checkGTIN(gtin)) // test function
            assert(gtin.isValidGTIN()) // test String extension
        }
    }

    func testInvalidGTINs() {
        let invalidGTINs = [
            "76308722791247", // GTIN-14 with wrong check key
            "7630872279123", // GTIN-13 with wrong check key
            "763087227911", // GTIN-12 with wrong check key
            "76308726", // GTIN-8 with wrong check key
            "0", // wrong length
            "abcdabcd", // right length, no integers
            "9876543a" // right length, not all integers
        ]
        invalidGTINs.forEach { gtin in
            assert(!checkGTIN(gtin)) // test function
            assert(!gtin.isValidGTIN()) // test String extension
        }
    }
}

