//
//  UITableViewExtensions.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

public protocol NibProvidable {
    static var nibName: String { get }
    static var nib: UINib { get }
}

extension NibProvidable {
    public static var nibName: String {
        return "\(self)"
    }
    public static var nib: UINib {
        return UINib(nibName: self.nibName, bundle: nil)
    }
}

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
    public func registerClass<T : UITableViewCell where T: ReusableView>(cellClass `class`: T.Type) {
        registerClass(`class`, forCellReuseIdentifier: `class`.reuseIdentifier)
    }

    public func registerNib<T: UITableViewCell where T: protocol<NibProvidable, ReusableView>>(cellClass `class`: T.Type) {
        registerNib(`class`.nib, forCellReuseIdentifier: `class`.reuseIdentifier)
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
    public func registerHeaderFooterClass<T: UITableViewHeaderFooterView where T: ReusableView>(headerFooterClass `class`: T.Type) {
        registerClass(`class`, forHeaderFooterViewReuseIdentifier: `class`.reuseIdentifier)
    }

    public func registerHeaderFooterNib<T: UITableViewHeaderFooterView where T: protocol<NibProvidable, ReusableView>>(forHeaderFooterClass `class`: T.Type) {
        registerNib(`class`.nib, forHeaderFooterViewReuseIdentifier: `class`.reuseIdentifier)
    }

    public func dequeueResuableHeaderFooterView<T: UITableViewHeaderFooterView where T: ReusableView>(withClass `class`: T.Type) -> T? {
        return dequeueReusableHeaderFooterViewWithIdentifier(`class`.reuseIdentifier) as? T
    }
}


