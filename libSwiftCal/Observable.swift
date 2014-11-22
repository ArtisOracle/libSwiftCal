//
//  Observable.swift
//  MyList
//
//  Created by Stefan Arambasich on 10/11/14.
//  Copyright (c) 2014 Stefan Arambasich. All rights reserved.
//

import Foundation

@objc protocol Observable {
    optional func addObserver(observer o: Observer)
    optional func removeObserver(observer o: Observer)
}

//protocol ObservableCollection {
//    func refreshCollection<T: CalendarType>(type: T)
//    
//    var listeners: [CollectionObserver] { get }
//    func addListener(listener l: CollectionObserver)
//    func removeListener(listener l: CollectionObserver)
//}