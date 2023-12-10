import java.io.File
import java.util.*

fun main(args: Array<String>) {
    val grid = readInputFile()
        .filter { it.isNotEmpty() }
        .mapIndexed { index, line -> processLine(line, index) }

    val vertices = grid.flatten().filterNotNull()

    val start = vertices.first { it.isStart }
    val graph = processVertices(vertices)
    val distances = graph.bfs(start.coords)
    val maxDistance = distances.maxOfOrNull { it.second }
    println("First part: $maxDistance")

    graph.filterVerticesNotConnectedTo(start.coords)
    val count = findEnclosedNum(grid, graph)
    println("Second part: $count")
}

fun readInputFile(fileName: String = "inputs/input") =
    File(fileName)
        .inputStream()
        .bufferedReader()
        .lineSequence()
        .toList()

fun processLine(line: String, y: Int): List<PossibleVertex?> =
    line.mapIndexed { index, c ->
        when (c) {
            '.' -> null
            '|' -> PossibleVertex(
                coords = Coordinate(index, y),
                possiblyConnects = listOf(Coordinate(index, y - 1), Coordinate(index, y + 1)),
                isBarrier = true,
            )
            '-' -> PossibleVertex(
                coords = Coordinate(index, y),
                possiblyConnects = listOf(Coordinate(index - 1, y), Coordinate(index + 1, y)),
            )
            'L' -> PossibleVertex(
                coords = Coordinate(index, y),
                possiblyConnects = listOf(Coordinate(index, y - 1), Coordinate(index + 1, y)),
            )
            'J' -> PossibleVertex(
                coords = Coordinate(index, y),
                possiblyConnects = listOf(Coordinate(index, y - 1), Coordinate(index - 1, y)),
            )
            '7' -> PossibleVertex(
                coords = Coordinate(index, y),
                possiblyConnects = listOf(Coordinate(index - 1, y), Coordinate(index, y+1)),
                isBarrier = true,
            )
            'F' -> PossibleVertex(
                coords = Coordinate(index, y),
                possiblyConnects = listOf(Coordinate(index + 1, y), Coordinate(index, y+1)),
                isBarrier = true,
            )
            'S' -> PossibleVertex(
                coords = Coordinate(index, y),
                possiblyConnects =  listOf(
                    Coordinate(index, y - 1),
                    Coordinate(index, y +1),
                    Coordinate(index - 1, y),
                    Coordinate(index + 1, y),
                ),
                isStart = true,
                isBarrier = true, // yolo?
            )
            else -> throw Exception("Unexpected character $c")
        }
    }

data class Coordinate(val x: Int, val y: Int)

data class PossibleVertex(
    val coords: Coordinate,
    val possiblyConnects: List<Coordinate>,
    val isStart: Boolean = false,
    val isVerticalBarrier: Boolean = false,
    val isHorizontalBarrier: Boolean = false,
    val isBarrier: Boolean = false
)

class Graph {
    val vertices = mutableSetOf<Coordinate>()
    val edges = mutableMapOf<Coordinate, Set<Coordinate>>()

    fun filterEdges() {
        edges.forEach { (coords, connectsTo) ->
            edges[coords] = connectsTo
                .filter { vertices.contains(it) }
                .filter { edges[it]?.contains(coords) ?: false }
                .toSet()
        }
    }

    fun filterVerticesNotConnectedTo(start: Coordinate) {
        val toRemove = mutableSetOf<Coordinate>()
        val reachable = bfs(start).map { it.first }
        vertices.forEach { coords ->
            if (!reachable.contains(coords)) {
                toRemove += coords
            }
        }
        vertices.removeAll(toRemove)
    }

    fun bfs(start: Coordinate): List<Pair<Coordinate, Int>> {
        val visited = mutableSetOf<Coordinate>()
        val queue: Queue<Pair<Coordinate, Int>> = LinkedList<Pair<Coordinate, Int>>()
        val traversalOrder = mutableListOf<Pair<Coordinate, Int>>()

        queue.add(Pair(start, 0))
        visited.add(start)

        while (queue.isNotEmpty()) {
            val (current, depth) = queue.remove()
            traversalOrder.add(Pair(current, depth))

            val neighbors = edges[current] ?: emptySet()
            for (neighbor in neighbors) {
                if (neighbor !in visited) {
                    visited.add(neighbor)
                    queue.add(Pair(neighbor, depth + 1))
                }
            }
        }

        return traversalOrder
    }

    fun isPart(coords: Coordinate) = vertices.contains(coords)
    fun isNeighbor(coords: Coordinate, neighbor: Coordinate) = edges[coords]!!.contains(neighbor) ?: false
}

fun processVertices(vertices: List<PossibleVertex>): Graph {
    val graph = Graph()

    vertices.forEach {
        graph.vertices.add(it.coords)
        graph.edges[it.coords] = it.possiblyConnects.toSet()
    }

    graph.filterEdges()

    return graph
}

fun findEnclosedNum(grid: List<List<PossibleVertex?>>, graph: Graph): Int {
    var count = 0

    grid.forEachIndexed { y, row ->
        row.forEachIndexed { x, vertex ->
            if (isInside(grid, graph, x, y)) {
                count++
            }
        }
    }

    return count
}

fun isInside(grid: List<List<PossibleVertex?>>, graph: Graph, x: Int, y: Int): Boolean {
    if (graph.isPart(Coordinate(x, y))) {
        return false
    }

    var cross = 0
    val line = grid[y]
    line.forEachIndexed { currX, it ->
        if (currX > x) {
            return@forEachIndexed
        }
        val isBarrier = it?.let {
            graph.isPart(it.coords) && it.isBarrier
        } ?: false
        if (isBarrier) {
            cross++
        }
    }

    return cross.isOdd()
}

fun Int.isOdd() = this % 2 == 1
