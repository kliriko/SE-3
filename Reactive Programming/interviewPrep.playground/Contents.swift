import Cocoa

var array: [Int] = [2, 7, 11, 15]
var seen: [Int : Int] = [:]

func find(target: Int, array: [Int], result: inout [Int : Int]) -> (Int, Int)? {
    for i in 0..<array.count {
        let riznycia = target - array[i]
        if let j = result[riznycia] {
            return (i, j)
        }
        result[array[i]] = i
    }
    return nil
}

func palindtome(_ string: String) -> Bool {
    var str = Array<Character>(string.lowercased())
    var endIndex = 0
    
    for i in 0..<str.count {
        if str[i] != str[str.count - 1 - endIndex] {
            return false
        }
        endIndex += 1
    }
    return true
}

func checkParanthesis(_ string: String) -> Bool{
    var stack: Array<Character> = []
    let pairs: [Character: Character] = [")": "(", "]": "[", "}": "{"]
    
    for char in string {
        if pairs.values.contains(char) {
            stack.append(char)
        } else {
            if stack.last != pairs[char]{
                return false
            }
            guard !stack.isEmpty else { return false }
        }
    }
    return stack.isEmpty
}

func kadanes(_ array: [Int]) -> Int {
    var bestSum = array[0]
    var currentSum = 0
    
    for i in 0..<array.count {
        currentSum = max(array[i], currentSum + array[i])
        bestSum = max(bestSum, currentSum)
    }
    
    return bestSum
}

func removeDuplicates<T: Hashable>(_ array: [T]) -> [T] {
    var seen: Set<T> = []
    for element in array {
        if !seen.contains(element) {
            seen.insert(element)
        }
    }
    return Array(seen)
}

func slidingWindow(_ string: String) -> Int {
    let str = Array(string)
    var seen: Set<Character> = []
    var left = 0
    var maxLen = 0
    
    for right in 0..<str.count {
        while seen.contains(str[right]) {
            seen.remove(str[left])
            left += 1
        }
        seen.insert(str[right])
        maxLen = max(maxLen, right - left + 1)
    }
    
    return maxLen
}

func hasPair (_ array: [Int]) -> [(Int, Int)] {
    var seen: Set<Int> = []
    var result: [(Int, Int)] = []
    
    for i in 0..<array.count {
        if seen.contains(-array[i]) {
            result.append((array[i], -array[i]))
        }
        
        seen.insert(array[i])
    }
    
    return result
}

func groupAnagrams(_ strings: [String]) -> [[String]] {
    var groups: [String: [String]] = [:]
    
    for string in strings {
        let key = String(string.sorted())
        groups[key, default: []].append(string)
    }
    
    return Array(groups.values)
}

func kupilprodal(_ array: [Int]) -> Int {
    var minPrice: Int = array[0]
    var bestDohid: Int = 0
    
    for i in 0..<array.count {
        minPrice = min(minPrice, array[i])
        bestDohid = max(bestDohid, array[i] - minPrice)
    }
    
    return bestDohid
}

class TreeNode {
    var val: Int
    var left: TreeNode?
    var right: TreeNode?
    init(_ val: Int) { self.val = val }
}

func getDepth(_ root: TreeNode?) -> Int{
    if root == nil { return 0 }
    
    return 1 + max(getDepth(root?.right), getDepth(root?.left))
}

func combinations(array: [Int], target: Int) -> [[Int]] {
    var result: [[Int]] = []
    var current: [Int] = []
    
    func backtrack(_ start: Int, _ remaining: Int) {
        if remaining == 0 {
            result.append(current)
            return
        }
        
        for i in start..<array.count {
            if array[i] > remaining { continue }
            current.append(array[i])
            backtrack(i, remaining - array[i])
            current.removeLast()
        }
    }
    backtrack(0, target)
    return result
}

// Do not remove any of the existing code below. This restores the previously deleted functions.

