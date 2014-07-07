//
//  UITableViewExtensions.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

public protocol ReusableView {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    public static var reuseIdentifier: String {
        return "\(self)"
    }
}

// Cell
extension UITableView {
    public func register<T : UITableViewCell where T: ReusableView>(cellClass `class`: T.Type) {
        registerClass(`class`, forCellReuseIdentifier: `class`.reuseIdentifier)
    }

    public func register<T: UITableViewCell where T: ReusableView>(nib: UINib, forClass `class`: T.Type) {
        registerNib(nib, forCellReuseIdentifier: `class`.reuseIdentifier)
    }

    public func dequeueReusableCell<T: UITableViewCell where T: ReusableView>(withClass `class`: T.Type) -> T? {
        return dequeueReusableCellWithIdentifier(`class`.reuseIdentifier) as? T
    }

    public func dequeueReusableCell<T: UITableViewCell where T: ReusableView>(withClass `class`: T.Type, forIndexPath indexPath: NSIndexPath) -> T! {
        guard let cell = dequeueReusableCellWithIdentifier(`class`.reuseIdentifier, forIndexPath: indexPath) as? T else {
            assert(false, "Error: cell with identifier: \(`class`.reuseIdentifier) for index path: \(indexPath) is not \(T.self)")
            return nil
        }
        return cell
    }
}

// Header / Footer
extension UITableView {
    public func register<T: UITableViewHeaderFooterView where T: ReusableView>(headerFooterClass `class`: T.Type) {
        registerClass(`class`, forHeaderFooterViewReuseIdentifier: `class`.reuseIdentifier)
    }

    public func register<T: UITableViewHeaderFooterView where T: ReusableView>(nib: UINib, forHeaderFooterClass `class`: T.Type) {
        registerNib(nib, forHeaderFooterViewReuseIdentifier: `class`.reuseIdentifier)
    }

    public func dequeueResuableHeaderFooterView<T: UITableViewHeaderFooterView where T: ReusableView>(withClass `class`: T.Type) -> T? {
        return dequeueReusableHeaderFooterViewWithIdentifier(`class`.reuseIdentifier) as? T
    }
}


