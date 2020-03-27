// https://github.com/Quick/Quick

import Quick
import Nimble
import Panda

class TableOfContentsSpec: QuickSpec {
    override func spec() {
//        describe("these will fail") {
//
//            it("can do maths") {
//                expect(1) == 2
//            }
//
//            it("can read") {
//                expect("number") == "string"
//            }
//
//            it("will eventually fail") {
//                expect("time").toEventually( equal("done") )
//            }
//
//            context("these will pass") {
//
//                it("can do maths") {
//                    expect(23) == 23
//                }
//
//                it("can read") {
//                    expect("🐮") == "🐮"
//                }
//
//                it("will eventually pass") {
//                    var time = "passing"
//
//                    DispatchQueue.main.async {
//                        time = "done"
//                    }
//
//                    waitUntil { done in
//                        Thread.sleep(forTimeInterval: 0.5)
//                        expect(time) == "done"
//
//                        done()
//                    }
//                }
//            }
//        }
        testExample()
    }
    
    func testExample() {
        let button = ButtonNode()
        button.setTitle("title", for: .normal)
        button.textNode.font = .systemFont(ofSize: 13)
        button.top == 0
        button.left == 0
        
        button.layoutIfNeeded()
        
        let size = button.sizeThatFit(.init(width: 1000, height: 1000))
        
        describe("buttonFrame") {
            print("frame: ", button.frame)
            print("size: ", size)
//            expect(size) == button.frame.size
            
        }
        
    }
}
