import java.io.File
import java.util.*

fun main(args: Array<String>) {
    val vertices =
        readInputFile()
            .filter { it.isNotEmpty() }
            .mapIndexed { index, line -> processLine(line, index) }
            .flatten()

    val start = vertices.first { it.isStart }
    val graph = processVertices(vertices, start)
    val distances = graph.bfs(start.coords)
    val maxDistance = distances.maxOfOrNull { it.second }
    println("First part: $maxDistance")
}

fun readInputFile(fileName: String = "inputs/input") =
    File(fileName)
        .inputStream()
        .bufferedReader()
        .lineSequence()
        .toList()

fun processLine(line: String, y: Int): List<PossibleVertex> =
    line.mapIndexed { index, c ->
        when (c) {
            '.' -> null
            '|' -> PossibleVertex(
                coords = Coordinate(index, y),
                possiblyConnects = listOf(Coordinate(index, y - 1), Coordinate(index, y + 1))
            )
            '-' -> PossibleVertex(
                coords = Coordinate(index, y),
                possiblyConnects = listOf(Coordinate(index - 1, y), Coordinate(index + 1, y))
            )
            'L' -> PossibleVertex(
                coords = Coordinate(index, y),
                possiblyConnects = listOf(Coordinate(index, y - 1), Coordinate(index + 1, y))
            )
            'J' -> PossibleVertex(
                coords = Coordinate(index, y),
                possiblyConnects = listOf(Coordinate(index, y - 1), Coordinate(index - 1, y))
            )
            '7' -> PossibleVertex(
                coords = Coordinate(index, y),
                possiblyConnects = listOf(Coordinate(index - 1, y), Coordinate(index, y+1))
            )
            'F' -> PossibleVertex(
                coords = Coordinate(index, y),
                possiblyConnects = listOf(Coordinate(index + 1, y), Coordinate(index, y+1))
            )
            'S' -> PossibleVertex(
                coords = Coordinate(index, y),
                possiblyConnects =  listOf(
                    Coordinate(index, y - 1),
                    Coordinate(index, y +1),
                    Coordinate(index - 1, y),
                    Coordinate(index + 1, y),
                ),
                isStart = true
            )
            else -> throw Exception("Unexpected character $c")
        }
    }.filterNotNull()

data class Coordinate(val x: Int, val y: Int)

data class PossibleVertex(val coords: Coordinate, val possiblyConnects: List<Coordinate>, val isStart: Boolean = false)

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

    fun filterVertices() {
        val toRemove = mutableSetOf<Coordinate>()
        vertices.forEach { coords ->
            if (edges[coords]?.isEmpty() != false) {
                toRemove.add(coords)
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
}

fun processVertices(vertices: List<PossibleVertex>, start: PossibleVertex): Graph {
    val vertexMap = vertices.associateBy { it.coords }
    val graph = Graph()

    vertices.forEach {
        graph.vertices.add(it.coords)
        graph.edges[it.coords] = it.possiblyConnects.toSet()
    }

    graph.filterEdges()
    graph.filterVertices()

    return graph
}

