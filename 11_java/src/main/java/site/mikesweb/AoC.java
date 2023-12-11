package site.mikesweb;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.*;
import java.util.stream.IntStream;

public class AoC {
    List<String> readFile() throws FileNotFoundException {
        var file = new File("inputs/input");
        var scanner = new Scanner(file);
        var lines = new ArrayList<String>();
        while (scanner.hasNextLine()) {
            var line = scanner.nextLine();
            lines.add(line);
        }
        return lines;
    }

    long solveForExpansion(int expansionSize) throws Exception {
        var lines = readFile();

        var expandedLineIndexes = new HashMap<Integer, Long>();
        var lastLineIndex = 0L;
        for (var i = 0; i < lines.size(); i++) {
            var line = lines.get(i);
            var noStars = line.chars().allMatch(by -> by == '.');
            if (noStars) {
                lastLineIndex += expansionSize;
            } else {
                expandedLineIndexes.put(i, lastLineIndex);
                lastLineIndex++;
            }
        }

        var expandedColumnIndexes = new HashMap<Integer, Long>();
        var rowSize = lines.get(0).length();
        var lastColumnIndex = 0L;
        for (var i = 0; i < rowSize; i++) {
            var allEmpty = true;
            for (var line : lines) {
                var ch = line.charAt(i);
                if (ch == '#') {
                    allEmpty = false;
                    break;
                }
            }

            if (allEmpty) {
                lastColumnIndex += expansionSize;
            } else {
                expandedColumnIndexes.put(i, lastColumnIndex);
                lastColumnIndex++;
            }
        }

        var galaxies = new ArrayList<Coordinate>();
        for (var y = 0; y < lines.size(); y++) {
            var line = lines.get(y);
            for (var x = 0; x < line.length(); x++) {
                var ch = line.charAt(x);
                if (ch == '#') {
                    var realY = expandedLineIndexes.get(y);
                    var realX = expandedColumnIndexes.get(x);
                    galaxies.add(new Coordinate(realX, realY));
                }
            }
        }

        var sum = 0L;
        for (var i = 0; i < galaxies.size(); i++) {
            var galaxy1 = galaxies.get(i);
            for (var j = i+1; j < galaxies.size(); j++) {
                var galaxy2 = galaxies.get(j);
                var distance = galaxy1.distanceTo(galaxy2);
                sum += distance;
            }
        }

        return sum;
    }

    void start() throws Exception {
        var first = solveForExpansion(2);
        System.out.printf("First part: %d\n", first);
        var second = solveForExpansion(1_000_000);
        System.out.printf("Second part: %d\n", second);
    }

    class Coordinate {
        public long x = 0;
        public long y = 0;
        public Coordinate(long x, long y) {
            this.x = x;
            this.y = y;
        }
        public long distanceTo(Coordinate coords) {
            return Math.abs(coords.x - x) + Math.abs(coords.y - y);
        }
    }
}
