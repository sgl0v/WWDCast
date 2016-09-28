//
//  UITableViewExtensions.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 05/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import UIKit

protocol NibProvidable {
    static var nibName: String { get }
    static var nib: UINib { get }
}

extension NibProvidable {
    static var nibName: String {
        return "\(self)"
    }
    static var nib: UINib {
        return UINib(nibName: self.nibName, bundle: nil)
    }
}

protocol ReusableView {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    static var reuseIdentifier: String {
        return "\(self)"
    }
}

protocol BindableView {
    associatedtype ViewModel
    func bindViewModel(viewModel: ViewModel)
}

// Cell
extension UITableView {
    func registerClass<T : UITableViewCell where T: ReusableView>(cellClass `class`: T.Type) {
        registerClass(`class`, forCellReuseIdentifier: `class`.reuseIdentifier)
    }

    func registerNib<T: UITableViewCell where T: protocol<NibProvidable, ReusableView>>(cellClass `class`: T.Type) {
        registerNib(`class`.nib, forCellReuseIdentifier: `class`.reuseIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell where T: ReusableView>(withClass `class`: T.Type) -> T? {
        return dequeueReusableCellWithIdentifier(`class`.reuseIdentifier) as? T
    }

    func dequeueReusableCell<T: UITableViewCell where T: ReusableView>(withClass `class`: T.Type, forIndexPath indexPath: NSIndexPath) -> T! {
        guard let cell = dequeueReusableCellWithIdentifier(`class`.reuseIdentifier, forIndexPath: indexPath) as? T else {
            assert(false, "Error: cell with identifier: \(`class`.reuseIdentifier) for index path: \(indexPath) is not \(T.self)")
            return nil
        }
        return cell
    }
}

// Header / Footer
extension UITableView {
    func registerHeaderFooterClass<T: UITableViewHeaderFooterView where T: ReusableView>(headerFooterClass `class`: T.Type) {
        registerClass(`class`, forHeaderFooterViewReuseIdentifier: `class`.reuseIdentifier)
    }

    func registerHeaderFooterNib<T: UITableViewHeaderFooterView where T: protocol<NibProvidable, ReusableView>>(forHeaderFooterClass `class`: T.Type) {
        registerNib(`class`.nib, forHeaderFooterViewReuseIdentifier: `class`.reuseIdentifier)
    }

    func dequeueResuableHeaderFooterView<T: UITableViewHeaderFooterView where T: ReusableView>(withClass `class`: T.Type) -> T? {
        return dequeueReusableHeaderFooterViewWithIdentifier(`class`.reuseIdentifier) as? T
    }
}


