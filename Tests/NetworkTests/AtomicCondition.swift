import Foundation

class AtomicCondition {
    var satisfied = false
    let condition = NSCondition()

    func signal() {
        condition.lock()
        satisfied = true
        condition.signal()
        condition.unlock()
    }

    func wait() {
        condition.lock()
        if !satisfied {
            condition.wait()
        }
        condition.unlock()
    }
}
