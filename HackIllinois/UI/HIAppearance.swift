//
//  HIAppearance.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 1/4/19.
//  Copyright © 2019 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import UIKit

struct HIAppearance: Equatable {
    let titleText: UIColor
    let baseText: UIColor
    let accent: UIColor
    let action: UIColor
    let baseBackground: UIColor
    let contentBackground: UIColor
    let overlay: UIColor
    let frostedTint: UIColor
    let qrTint: UIColor
    let qrBackground: UIColor
    let emptyTableViewBackground: UIImage
    let preferredStatusBarStyle: UIStatusBarStyle
    let scrollViewIndicatorStyle: UIScrollView.IndicatorStyle
    let mapBackground: UIColor

    let clear: UIColor = .clear

    private static let darkBlue = #colorLiteral(red: 0, green: 0.3411764706, blue: 0.462745098, alpha: 1)
    private static let blue = #colorLiteral(red: 0.1215686275, green: 0.5176470588, blue: 0.6470588235, alpha: 1)
    private static let lightBlue = #colorLiteral(red: 0.8901960784, green: 0.9647058824, blue: 1, alpha: 1)
    private static let white = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    private static let coral = #colorLiteral(red: 1, green: 0.4666666667, blue: 0.4352941176, alpha: 1)

    fileprivate static let day = HIAppearance(
        titleText: darkBlue,
        baseText: darkBlue,
        accent: coral,
        action: blue,
        baseBackground: lightBlue,
        contentBackground: white,
        overlay: #colorLiteral(red: 0.05882352941, green: 0.07058823529, blue: 0.1803921569, alpha: 0.33),
        frostedTint: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0),
        qrTint: blue,
        qrBackground: white,
        emptyTableViewBackground: #imageLiteral(resourceName: "EmptyTableViewDay"),
        preferredStatusBarStyle: .default,
        scrollViewIndicatorStyle: .black,
        mapBackground: blue
    )

    fileprivate static let night = HIAppearance(
        titleText: lightBlue,
        baseText: lightBlue,
        accent: coral,
        action: white,
        baseBackground: darkBlue,
        contentBackground: blue,
        overlay: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.47),
        frostedTint: #colorLiteral(red: 0, green: 0.3411764706, blue: 0.462745098, alpha: 0.6),
        qrTint: darkBlue,
        qrBackground: lightBlue,
        emptyTableViewBackground: #imageLiteral(resourceName: "EmptyTableViewNight"),
        preferredStatusBarStyle: .lightContent,
        scrollViewIndicatorStyle: .white,
        mapBackground: blue
    )

    fileprivate static var current = day

    static func change(to newAppearance: HIAppearance) {
        guard current != newAppearance else { return }
        current = newAppearance

        NotificationCenter.default.post(name: .themeDidChange, object: nil)
    }

    enum Font {
        static let contentSubtitle = UIFont.systemFont(ofSize: 13, weight: .light)
        static let contentText = UIFont.systemFont(ofSize: 13, weight: .regular)
        static let contentTitle = UIFont.systemFont(ofSize: 18, weight: .light)

        static let navigationSubtitle = UIFont.systemFont(ofSize: 13, weight: .medium)
        static let navigationTitle = UIFont.systemFont(ofSize: 15, weight: .medium)

        static let sectionHeader = UIFont.systemFont(ofSize: 13, weight: .bold)
        static let button = UIFont.systemFont(ofSize: 15, weight: .regular)
        static let glyph = UIFont.systemFont(ofSize: 21, weight: .light)
    }
}

// MARK: - HIApperanceKeyPath
extension KeyPath where Root == HIAppearance {
    var value: Value {
        return HIAppearance.current[keyPath: self]
    }
}

// MARK: - HIColor
typealias HIColor = KeyPath<HIAppearance, UIColor>

extension UIColor {
    static func <- (lhs: inout UIColor, rhs: HIColor) {
        lhs = rhs.value
    }
}

extension Optional where Wrapped == UIColor {
    static func <- (lhs: inout UIColor?, rhs: HIColor) {
        lhs = rhs.value
    }

    static func <- (lhs: inout UIColor?, rhs: HIColor?) {
        lhs = rhs?.value
    }
}

// MARK: - HIImage
typealias HIImage = KeyPath<HIAppearance, UIImage>

extension UIImage {
    static func <- (lhs: inout UIImage, rhs: HIImage) {
        lhs = rhs.value
    }
}

extension Optional where Wrapped == UIImage {
    static func <- (lhs: inout UIImage?, rhs: HIImage) {
        lhs = rhs.value
    }

    static func <- (lhs: inout UIImage?, rhs: HIImage?) {
        lhs = rhs?.value
    }
}

// MARK: - HIStatusBarStyle
typealias HIStatusBarStyle = KeyPath<HIAppearance, UIStatusBarStyle>

extension UIStatusBarStyle {
    static func <- (lhs: inout UIStatusBarStyle, rhs: HIStatusBarStyle) {
        lhs = rhs.value
    }
}

extension Optional where Wrapped == UIStatusBarStyle {
    static func <- (lhs: inout UIStatusBarStyle?, rhs: HIStatusBarStyle) {
        lhs = rhs.value
    }

    static func <- (lhs: inout UIStatusBarStyle?, rhs: HIStatusBarStyle?) {
        lhs = rhs?.value
    }
}

// MARK: - HIStatusBarStyle
typealias HIScrollViewIndicatorStyle = KeyPath<HIAppearance, UIScrollView.IndicatorStyle>

extension UIScrollView.IndicatorStyle {
    static func <- (lhs: inout UIScrollView.IndicatorStyle, rhs: HIScrollViewIndicatorStyle) {
        lhs = rhs.value
    }
}

extension Optional where Wrapped == UIScrollView.IndicatorStyle {
    static func <- (lhs: inout UIScrollView.IndicatorStyle?, rhs: HIScrollViewIndicatorStyle) {
        lhs = rhs.value
    }

    static func <- (lhs: inout UIScrollView.IndicatorStyle?, rhs: HIScrollViewIndicatorStyle?) {
        lhs = rhs?.value
    }
}

// MARK: - HIThemeEngine
class HIThemeEngine {
    static let shared = HIThemeEngine()

    // MARK: - Properties
    var timer: Timer?

    // MARK: - Init
    private init() {
        startUpTimer()
    }

    deinit {
        tearDownTimer()
    }

    // MARK: - Theme Timer
    func startUpTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 300, // every 5 minutes
            target: self,
            selector: #selector(updateThemeIfNeeded),
            userInfo: nil,
            repeats: true
        )
        timer?.fire()
    }

    @objc func updateThemeIfNeeded() {
        let calendar = Calendar.current
        let now = Date()
        guard let sunrise = calendar.date(bySettingHour: 6, minute: 30, second: 0, of: now),
            let sunset = calendar.date(bySettingHour: 17, minute: 30, second: 0, of: now) else { return }

        let newAppearance: HIAppearance
        if now >= sunrise && now <= sunset {
            newAppearance = .day
        } else {
            newAppearance = .night
        }
        HIAppearance.change(to: newAppearance)
    }

    func tearDownTimer() {
        timer?.invalidate()
        timer = nil
    }
}
