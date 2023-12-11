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

    int solve() throws Exception {
        var lines = readFile();

        var doubledLines = new ArrayList<String>();
        for (var line : lines) {
            if (line.isBlank()) {
                continue;
            }

            var noStars = line.chars().allMatch(by -> by == '.');
            if (noStars) {
                doubledLines.add(line);
            }
            doubledLines.add(line);
        }

        var rowsToDouble = new ArrayList<Integer>();
        var rowSize = doubledLines.get(0).length();
        for (var i = 0; i < rowSize; i++) {
            int finalI = i;
            var rowIsEmpty = doubledLines.stream()
                    .map(line -> line.charAt(finalI))
                    .allMatch(it -> it.equals('.'));
            if (rowIsEmpty) {
                rowsToDouble.add(0, i);
            }
        }
        List<String> grownMap = doubledLines;
        for (var row : rowsToDouble) {
            grownMap = grownMap.stream().map(line -> line.substring(0, row) + "." + line.substring(row)).toList();
        }

        var galaxies = new ArrayList<Coordinate>();
        for (var y = 0; y < grownMap.size(); y++) {
            var line = grownMap.get(y);
            for (var x = 0; x < line.length(); x++) {
                var ch = line.charAt(x);
                if (ch == '#') {
                    galaxies.add(new Coordinate(x, y));
                }
            }
        }

        var sum = 0;
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
        var first = solve();
        System.out.printf("First part: %s\n", first);
    }

    class Coordinate {
        public int x = 0;
        public int y = 0;
        public Coordinate(int x, int y) {
            this.x = x;
            this.y = y;
        }
        public int distanceTo(Coordinate coords) {
            return Math.abs(coords.x - x) + Math.abs(coords.y - y);
        }
    }
}
