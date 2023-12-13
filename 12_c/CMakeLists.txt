cmake_minimum_required(VERSION 3.16)
project(aoc C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_FLAGS "-Wall -Wextra -Wpedantic -O3")

add_executable(aoc main.c)
