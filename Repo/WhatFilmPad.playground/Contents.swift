//: Playground - noun: a place where people can play

import PlaygroundSupport
import RxSwift

PlaygroundPage.current.needsIndefiniteExecution = true




var trigger: Observable<Void> = Observable.empty()

let observable: Observable<String> = [
    Observable.just("First"),
    Observable.never().takeUntil(trigger),
    Observable.just("Second")
].concat()

observable.asObservable().subscribe { value in
    print(value)
}
