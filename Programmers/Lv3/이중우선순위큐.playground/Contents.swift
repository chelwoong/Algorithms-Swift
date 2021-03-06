import Foundation

public struct Heap<T> {
    
    var nodes = [T]()
    
    private var orderCriteria: (T, T) -> Bool
    
    public init(sort: @escaping (T, T) -> Bool) {
        // 최대 힙인지 최소 힙인지 기준을 잡는다.
        self.orderCriteria = sort
    }
    
    public init(array: [T], sort: @escaping (T, T) -> Bool) {
        self.orderCriteria = sort
        configureHeap(from: array)
    }
    
    // 변수를 직접 변경해야 하기 때문에 mutating 을 사용한다.
    private mutating func configureHeap(from array: [T]) {
        nodes = array
        
        /**
         * 힙 트리에서 n/2 - 1 은 하나 위 층위가 된다.
         * shiftDown을 하면서 자리를 잡을 것이기 때문에
         * 마지막 leaf 노드들은 할 필요가 없다.
         */
        for i in stride(from: nodes.count/2 - 1, through: 0, by: -1) {
            shiftDown(i)
        }
    }
    
    func parentIndex(ofIndex i: Int) -> Int {
        return (i - 1) / 2
    }
    
    func leftChildIndex(ofIndex i: Int) -> Int {
        return 2*i + 1
    }
    
    func rightChildIndex(ofIndex i: Int) -> Int {
        return 2*i + 2
    }
    
    public func peek() -> T? {
        return nodes.first
    }
    
    public mutating func insert(_ value: T) {
        nodes.append(value)
        shiftUp(nodes.count - 1)
    }
    
    public mutating func remove() -> T? {
        guard !nodes.isEmpty else { return nil }
        
        if nodes.count == 1 {
            return nodes.removeLast()
        } else {
            let value = nodes[0]
            nodes[0] = nodes.removeLast()
            shiftDown(0)
            return value
        }
    }
    
    public mutating func remove(at index: Int) -> T? {
        guard index < nodes.count else { return nil }
        
        let lastIndex = nodes.count-1
        if index != lastIndex {
            nodes.swapAt(index, lastIndex)
            shiftDown(from: index, until: lastIndex)
            shiftUp(index)
        }
        
        return nodes.removeLast()
    }
    
    /**
     * shiftUp은 자신과 부모를 비교해 바꿔준다.
     */
    mutating func shiftUp(_ index: Int) {
        var childIndex = index
        let child = nodes[childIndex] // 처음에 노드를 저장해두고 인덱스를 구한 후 바꿔준다.
        var parentIndex = self.parentIndex(ofIndex: index)
        
        while childIndex > 0 && orderCriteria(child, nodes[parentIndex]) {
            nodes[childIndex] = nodes[parentIndex]
            childIndex = parentIndex
            parentIndex = self.parentIndex(ofIndex: childIndex)
        }
        
        nodes[childIndex] = child
    }
    
    /**
     * shiftDown은 left, right 자식 중 적합한 녀석이 있으면 바꾸면서 바닥까지 내려간다.
     */
    mutating func shiftDown(from index: Int, until endIndex: Int) {
        let leftChildIndex = self.leftChildIndex(ofIndex: index)
        let rightChildIndex = leftChildIndex + 1
        
        var first = index
        if leftChildIndex < endIndex && orderCriteria(nodes[leftChildIndex], nodes[first]) {
            first = leftChildIndex
        }
        if rightChildIndex < endIndex && orderCriteria(nodes[rightChildIndex], nodes[first]) {
            first = rightChildIndex
        }
        if first == index { return }
        
        nodes.swapAt(index, first)
        shiftDown(from: first, until: endIndex)
    }
    
    mutating func shiftDown(_ index: Int) {
        shiftDown(from: index, until: nodes.count)
    }
    
}

extension Heap where T: Equatable {
    
    /** 특정 노드의 index 얻기. O(n) */
    public func index(of node: T) -> Int? {
        return nodes.firstIndex(where: { $0 == node })
    }
    
    public mutating func remove(node: T) -> T? {
        if let index = index(of: node) {
            return remove(at: index)
        }
        return nil
    }
}


func solution(_ operations:[String]) -> [Int] {
    
    var maxHeap = Heap<Int>(sort: >)
    var minHeap = Heap<Int>(sort: <)
    
    var result = [Int]()
    
    for operation in operations {
        let opt = operation.components(separatedBy: " ")
        
        if opt[0] == "I", let value = Int(opt[1]) {
            maxHeap.insert(value)
            minHeap.insert(value)
        } else if opt[0] == "D"{
            let order = opt[1]
            
            if order == "1" {
                if let node = maxHeap.remove() {
                    minHeap.remove(node: node)
                }
            } else {
                if let node = minHeap.remove() {
                    maxHeap.remove(node: node)
                }
            }
        }
//        print(opt, maxHeap, minHeap)
    }
    
    result.append(maxHeap.peek() ?? 0)
    result.append(minHeap.peek() ?? 0)
    
    return result
}


solution(["I 7","I 5","I -5","D -1"])
