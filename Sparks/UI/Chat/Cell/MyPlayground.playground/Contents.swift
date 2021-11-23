import UIKit

let condi = NSCondition()
var availailable = false

class Writer : Thread {
    override func main() {
        condi.lock()
        print("writer started")
        condi.signal()
      //
        condi.signal()
        print("unlock")
        condi.unlock()
        print("writer exit")
         availailable = true
    }
}

class Reader : Thread {
    override func main() {
        condi.lock()
        print("reader started")
        while(!availailable){
            print("wainting")
            condi.wait()
        }
        availailable = false
        condi.unlock()
        print("reader enden")
    }
}

let writer = Writer()
let reader = Reader()

reader.start()
writer.start()

