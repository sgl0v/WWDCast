//
//  SessionsSearchPresenterImpl.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 04/07/16.
//  Copyright © 2016 Maksym Shcheglov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct Titles {
    static let SessionsSearchViewTitle = NSLocalizedString("WWDCast", comment: "Session search view title")
    static let SessionDetailsViewTitle = NSLocalizedString("Session Details", comment: "Session details view title")
}

class SessionsSearchPresenterImpl: SessionsSearchPresenter {
    var interactor: SessionsSearchInteractor!
    var router: SessionsSearchRouter
    private var filter: Variable<Filter>
    var isLoading: Observable<Bool> {
        return _isLoading
    }
    private let _sessions: Variable<[SessionViewModels]>
    private let _isLoading = BehaviorSubject(value: false);
    private let disposeBag = DisposeBag()
    
    /// Underlying variable that we'll listen to for changes
    private var _active = Variable(false)
    
    /// Public «active» variable
    var active: Bool {
        get { return _active.value }
        set {
            // Skip KVO notifications when the property hasn't actually changed.
            if newValue == _active.value { return }
            
            _active.value = newValue
        }
    }
    
    /**
  Rx `Observable` for the `active` flag. (when it becomes `true`).
  
  Will send messages only to *new* & *different* values.
  */
  lazy var didBecomeActive: Observable<SessionsSearchPresenterImpl> = { [unowned self] in
    return self._active.asObservable()
        .filter { $0 == true }
        .map { _ in return self }
  }()
  
  /**
  Rx `Observable` for the `active` flag. (when it becomes `false`).
  
  Will send messages only to *new* & *different* values.
  */
  lazy var didBecomeInactive: Observable<SessionsSearchPresenterImpl> = { [unowned self] in
    return self._active.asObservable()
        .filter { $0 == false }
        .map { _ in return self }
  }()

    init(router: SessionsSearchRouter) {
        self.router = router
        self.filter = Variable(Filter())
        self.title = Driver.just(Titles.SessionsSearchViewTitle)
        self._sessions = Variable([])

        self.didBecomeActive.subscribeNext({ viewModel in
            Observable.combineLatest(viewModel.interactor.loadSessions(), viewModel.filter.asObservable(), resultSelector: self.applyFilter)
                .asDriver(onErrorJustReturn: [])
                .map(SessionViewModelBuilder.build)
                .drive(viewModel._sessions)
                .addDisposableTo(viewModel.disposeBag)
        }).addDisposableTo(self.disposeBag)
    }
    
    private func applyFilter(sessions: [Session], filter: Filter) -> [Session] {
        return sessions.filter { session in
            (filter.query.isEmpty || session.title.containsString(filter.query)) &&
                filter.tracks.contains(session.track) &&
                !Set(filter.platforms).intersect(session.platforms).isEmpty
        }
    }
    
    // MARK: SessionsSearchPresenter
    
    var sessions: Driver<[SessionViewModels]> {
        return self._sessions.asDriver()
    }
    let title: Driver<String>

    var itemSelected: AnyObserver<SessionViewModel> {
        return AnyObserver {[unowned self] event in
            guard case .Next(let session) = event else {
                return
            }
            self.router.showSessionDetails(withId: session.uniqueID)
        }
    }
    
    var filterObserver: AnyObserver<Void> {
        return AnyObserver {[unowned self] event in
            guard case .Next = event else {
                return
            }
            self.router.showFilterController(withFilter: self.filter.value) {[unowned self] filter in
                self.filter.value = filter
            }
        }
    }
    
    var searchStringObserver: AnyObserver<String> {
        return AnyObserver {[unowned self] event in
            guard case .Next(let query) = event else {
                return
            }
            var filter = self.filter.value
            filter.query = query
            self.filter.value = filter
        }
    }

}
