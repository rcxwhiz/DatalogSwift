class RuleOptimizer {
    static func group(rules: [Rule]) -> [[Rule]] {
        var dependencies: [[Bool]] = Array(repeating: Array(repeating: false, count: rules.count), count: rules.count)
        
        for i in 0..<rules.count {
            for j in 0..<rules.count {
                for scheme in rules[i].schemes {
                    if rules[j].headPredicate.name == scheme.name {
                        dependencies[i][j] = true
                        break
                    }
                }
            }
        }

        var visited: [Bool] = Array(repeating: false, count: rules.count)
        var postOrderNums: [Int] = Array(repeating: 0, count: rules.count)
        for i in 0..<rules.count {
            if !visited[i] {
                poDfs(graph: dependencies, visited: &visited, edge: i, postOrderNums: &postOrderNums)
            }
        }

        var highestNotVisited = 0
        visited = Array(repeating: false, count: rules.count)
        var groups: [[Int]] = [[]]
        while !(visited.filter { !$0 }.isEmpty) {
            for i in 0..<rules.count {
                if postOrderNums[i] > postOrderNums[highestNotVisited] && !visited[i] {
                    highestNotVisited = i
                }
                dfs(graph: dependencies, visited: &visited, edge: i, groups: &groups)
            }
        }
        return groups.map { i in i.map { j in rules[j] } }
    }
}

extension RuleOptimizer {
    private static func poDfs(graph: [[Bool]], visited: inout [Bool], edge: Int, postOrderNums: inout [Int]) {
        visited[edge] = true
        for i in 0..<graph.count {
            if graph[edge][i] && !visited[i] {
                poDfs(graph: graph, visited: &visited, edge: i, postOrderNums: &postOrderNums)
            }
        }
        postOrderNums[edge] = visited.filter { $0 }.count
    }

    private static func dfs(graph: [[Bool]], visited: inout [Bool], edge: Int, groups: inout [[Int]]) {
        visited[edge] = true
        groups[groups.count - 1].append(edge)
        for i in 0..<graph.count {
            if graph[i][edge] && !visited[i] {
                dfs(graph: graph, visited: &visited, edge: i, groups: &groups)
            }
        }
    }
}
