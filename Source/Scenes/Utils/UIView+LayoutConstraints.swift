//
//  UIView+LayoutConstraints.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 03/12/2017.
//  Copyright © 2017 Maksym Shcheglov. All rights reserved.
//

import UIKit

typealias Constraint = (_ child: UIView, _ parent: UIView) -> NSLayoutConstraint

func equal<Anchor, Axis>(_ keyPath: KeyPath<UIView, Anchor>) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return { view, parent in
        view[keyPath: keyPath].constraint(equalTo: parent[keyPath: keyPath])
    }
}

func equal<Anchor, Axis>(_ keyPaths: [KeyPath<UIView, Anchor>]) -> [Constraint] where Anchor: NSLayoutAnchor<Axis> {
    return keyPaths.map { keyPath in
        return equal(keyPath)
    }
}

func equal<Anchor>(_ keyPath: KeyPath<UIView, Anchor>, to constant: CGFloat) -> Constraint where Anchor: NSLayoutDimension {
    return { view, parent in
        view[keyPath: keyPath].constraint(equalToConstant: constant)
    }
}

func equal<Anchor, Axis>(_ from: KeyPath<UIView, Anchor>, _ to: KeyPath<UIView, Anchor>) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return { view, parent in
        view[keyPath: from].constraint(equalTo: parent[keyPath: to])
    }
}

extension UIView {

    func addSubview(_ subview: UIView, constraints: [Constraint]) {
        self.addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints.map { constraint in
            return constraint(subview, self)
        })
    }
}
