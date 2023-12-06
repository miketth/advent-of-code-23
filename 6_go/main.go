package main

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
)

func main() {
	if err := run(); err != nil {
		log.Fatalf("%+v", err)
	}
}

func run() error {
	races, err := parseInput()
	if err != nil {
		return fmt.Errorf("parse input: %w", err)
	}

	product := 1
	for _, race := range races {
		wins := calcWinningDistances(race)
		product *= len(wins)
	}

	fmt.Printf("First part: %d\n", product)

	bigRace := oneRace(races)
	wins := calcWinningDistances(bigRace)
	fmt.Printf("Second part: %d\n", len(wins))

	return nil
}

type Race struct {
	Time     int
	Distance int
}

func parseInput() ([]Race, error) {
	contentsBy, err := os.ReadFile("inputs/input")
	if err != nil {
		return nil, fmt.Errorf("read file: %w", err)
	}

	contents := string(contentsBy)
	contents = strings.TrimSpace(contents)

	lines := strings.Split(contents, "\n")

	times, err := getNums(lines[0])
	if err != nil {
		return nil, fmt.Errorf("get times: %w", err)
	}

	distances, err := getNums(lines[1])
	if err != nil {
		return nil, fmt.Errorf("get distances: %w", err)
	}

	if len(times) != len(distances) {
		return nil, fmt.Errorf("times and distances must be the same length")
	}

	races := make([]Race, len(times))
	for i := range times {
		races[i] = Race{
			Time:     times[i],
			Distance: distances[i],
		}
	}

	return races, nil
}

func getNums(line string) ([]int, error) {
	parts := strings.Fields(line)
	parts = parts[1:]

	nums := make([]int, len(parts))
	for i, part := range parts {
		num, err := strconv.Atoi(part)
		if err != nil {
			return nil, fmt.Errorf("error converting string to int: %w", err)
		}
		nums[i] = num
	}

	return nums, nil
}

func calcWinningDistances(race Race) []int {
	var distances []int
	for tBtn := 0; tBtn < race.Time; tBtn++ {
		distance := tBtn * (race.Time - tBtn)
		if distance > race.Distance {
			distances = append(distances, distance)
		}
	}
	return distances
}

func oneRace(races []Race) Race {
	timeDigits := ""
	distanceDigits := ""
	for _, race := range races {
		time := strconv.Itoa(race.Time)
		distance := strconv.Itoa(race.Distance)

		timeDigits += time
		distanceDigits += distance
	}

	time, _ := strconv.Atoi(timeDigits)
	distance, _ := strconv.Atoi(distanceDigits)

	return Race{
		Time:     time,
		Distance: distance,
	}
}
