//
//  MazeGenerator.swift
//  Marble-Maze
//
//  Created by 90307332 on 2/25/20.
//  Copyright © 2020 Ishan Shetty. All rights reserved.
//

class MazeGenerator {
    
    private let xDirs = [1, -1, 0, 0]
    private let yDirs = [0, 0, 1, -1]
    
    func generateMaze(width: Int, height:Int, startX: Int, startY: Int) -> [[Bool]] {
        var maze = fillMaze(width: width, height: height)
        maze = createPath(maze: maze, x: startX, y: startY)
        return createStartAndEnd(maze: maze)
    }
    
    func extendMaze(maze: [[Bool]], addOn: Int) -> [[Bool]] {
        var extraMaze = fillMaze(width: addOn, height: maze.count)
        extraMaze = createPath(maze: extraMaze, x: maze.count-1, y: 1)
        
        var newMaze = maze
        for i in 0 ..< maze.count {
            for j in 0 ..< addOn {
                newMaze[i].append(extraMaze[j][i])
            }
        }

        newMaze[1][newMaze[0].count-1] = false
        return createPath(maze: newMaze, x: maze.count-2, y: maze[0].count)
    }
    
    private func createPath(maze: [[Bool]], x: Int, y: Int) -> [[Bool]] {
        var newMaze = maze
        var d = Int.random(in: 0...3)
        for _ in 0 ..< xDirs.count {
            let node1 = (x + xDirs[d], y + yDirs[d])
            let node2 = (node1.0 + xDirs[d], node1.1 + yDirs[d])
            let valid = validNode(maze: newMaze, node: node1) && validNode(maze: newMaze, node: node2)
            let blocked = valid ? newMaze[node1.0][node1.1] && newMaze[node2.0][node2.1] : false
            
            if blocked {
                newMaze[node1.0][node1.1] = false
                newMaze[node2.0][node2.1] = false
                newMaze = createPath(maze: newMaze, x: node2.0, y: node2.1)
            }
            
            d = (d+1) % 4
        }
        
        return newMaze
    }
    
    private func createStartAndEnd(maze: [[Bool]]) -> [[Bool]] {
        var newMaze = maze
        newMaze[1][0] = false
        newMaze[maze.count-2][maze[0].count-1] = false
        return newMaze
    }
    
    private func fillMaze(width: Int, height:Int) -> [[Bool]] {
        var maze = [[Bool]]()
        for _ in 0 ..< width {
            var row = [Bool]()
            for _ in 0 ..< height {
                row.append(true)
            }
            
            maze.append(row)
        }
        
        return maze
    }
    
    func validNode(maze: [[Bool]], node: (Int, Int)) -> Bool {
        return node.0 >= 0 && node.0 < maze.count && node.1 >= 0 && node.1 < maze[0].count
    }
}
