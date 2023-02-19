//
//  Protocol+Ext.swift
//  TodoListMission
//
//  Created by 김라영 on 2023/02/06.
//

import Foundation
import UIKit

protocol Nibbed {
    static var uiNib: UINib { get }
}

extension Nibbed {
    static var uiNib: UINib {
        return UINib(nibName: String(describing: Self.self), bundle: nil)
    }
}

extension UITableViewCell: Nibbed {}

protocol ReuseIdentifier {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifier {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UITableViewCell: ReuseIdentifier {}

protocol WithIdentifier {
    static var withIdentifier: String { get }
}

extension WithIdentifier {
    static var withIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UIViewController: WithIdentifier {}

