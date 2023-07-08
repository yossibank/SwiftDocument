import WWDC

let a = 17
let b = 25

let (result, code) = #stringify(a + b)

print("The value \(result) was produced by the code \"\(code)\"")

// @EnumSubset can only be applied to an enum
//@EnumSubset
//struct Skier {
//}
