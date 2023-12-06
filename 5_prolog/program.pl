read_file_to_string(FilePath, String) :-
    open(FilePath, read, Stream),
    read_string(Stream, _, String),
    close(Stream).

split_string_into_lines(String, Lines) :-
    split_string(String, "\n", "", Lines).

split_seed_and_maps(Lines, SeedLine, MapLines) :-
  [SeedLine | Rest] = Lines,
  [_ | MapLines] = Rest.

seed_soil_header("seed-to-soil map:").
soil_fertilizer_header("soil-to-fertilizer map:").
fertilizer_water_header("fertilizer-to-water map:").
water_light_header("water-to-light map:").
light_temperature_header("light-to-temperature map:").
temperature_humidity_header("temperature-to-humidity map:").
humidity_location_header("humidity-to-location map:").

split_by_empty_line([], [], []).
split_by_empty_line([Line | RestOfLines], [Line | RestBefore], After) :-
  Line \= "",
  split_by_empty_line(RestOfLines, RestBefore, After).
split_by_empty_line(["" | RestOfLines], [], RestOfLines).


% end of file
extract_maps([], _, _, _, _, _, _, _).

% seed to soil
extract_maps([Line | Rest], SeedToSoil, SoilToFertilizer, FertilizerToWater, WaterToLight, LightToTemperature, TemperatureToHumidity, HumidityToLocation) :-
  seed_soil_header(Line),
  split_by_empty_line(Rest, SeedToSoil, RestAfter),
  extract_maps(RestAfter, _, SoilToFertilizer, FertilizerToWater, WaterToLight, LightToTemperature, TemperatureToHumidity, HumidityToLocation).

% soil to fertilizer
extract_maps([Line | Rest], SeedToSoil, SoilToFertilizer, FertilizerToWater, WaterToLight, LightToTemperature, TemperatureToHumidity, HumidityToLocation) :-
  soil_fertilizer_header(Line),
  split_by_empty_line(Rest, SoilToFertilizer, RestAfter),
  extract_maps(RestAfter, SeedToSoil, _, FertilizerToWater, WaterToLight, LightToTemperature, TemperatureToHumidity, HumidityToLocation).

% fertilizer to water
extract_maps([Line | Rest], SeedToSoil, SoilToFertilizer, FertilizerToWater, WaterToLight, LightToTemperature, TemperatureToHumidity, HumidityToLocation) :-
  fertilizer_water_header(Line),
  split_by_empty_line(Rest, FertilizerToWater, RestAfter),
  extract_maps(RestAfter, SeedToSoil, SoilToFertilizer, _, WaterToLight, LightToTemperature, TemperatureToHumidity, HumidityToLocation).

% water to light
extract_maps([Line | Rest], SeedToSoil, SoilToFertilizer, FertilizerToWater, WaterToLight, LightToTemperature, TemperatureToHumidity, HumidityToLocation) :-
  water_light_header(Line),
  split_by_empty_line(Rest, WaterToLight, RestAfter),
  extract_maps(RestAfter, SeedToSoil, SoilToFertilizer, FertilizerToWater, _, LightToTemperature, TemperatureToHumidity, HumidityToLocation).

% light to temperature
extract_maps([Line | Rest], SeedToSoil, SoilToFertilizer, FertilizerToWater, WaterToLight, LightToTemperature, TemperatureToHumidity, HumidityToLocation) :-
  light_temperature_header(Line),
  split_by_empty_line(Rest, LightToTemperature, RestAfter),
  extract_maps(RestAfter, SeedToSoil, SoilToFertilizer, FertilizerToWater, WaterToLight, _, TemperatureToHumidity, HumidityToLocation).

% temperature to humidity
extract_maps([Line | Rest], SeedToSoil, SoilToFertilizer, FertilizerToWater, WaterToLight, LightToTemperature, TemperatureToHumidity, HumidityToLocation) :-
  temperature_humidity_header(Line),
  split_by_empty_line(Rest, TemperatureToHumidity, RestAfter),
  extract_maps(RestAfter, SeedToSoil, SoilToFertilizer, FertilizerToWater, WaterToLight, LightToTemperature, _, HumidityToLocation).

% humidity to location
extract_maps([Line | Rest], SeedToSoil, SoilToFertilizer, FertilizerToWater, WaterToLight, LightToTemperature, TemperatureToHumidity, HumidityToLocation) :-
  humidity_location_header(Line),
  split_by_empty_line(Rest, HumidityToLocation, RestAfter),
  extract_maps(RestAfter, SeedToSoil, SoilToFertilizer, FertilizerToWater, WaterToLight, LightToTemperature, TemperatureToHumidity, _).

split_string_into_nums(String, Nums) :-
  split_string(String, " ", "", Strings),
  maplist(number_string, Nums, Strings).

parse_map([], []).
parse_map([Line | Rest], [Rule|RestOfRules]) :-
  split_string_into_nums(Line, [To, From, Range]),
  Rule = rule(From, To, Range),
  parse_map(Rest, RestOfRules).

parse_all_maps([], []).
parse_all_maps([Map|Rest], [ParsedMap|RestOfParsedMaps]) :-
  parse_map(Map, ParsedMap),
  parse_all_maps(Rest, RestOfParsedMaps).

get_next_num([Rule|MoreRules], Current, Next) :-
  (apply_rule(Rule, Current, Next), !);
  (get_next_num(MoreRules, Current, Next), !).

apply_rule(rule(From, To, _), Current, Next) :-
  %UpperBound is From + Range,
  Current >= From,
  %Current < UpperBound,
  Delta is To - From,
  Next is Current + Delta.

apply_all_maps([], Location, Location).
apply_all_maps([Map|Rest], Seed, Location) :-
  get_next_num(Map, Seed, NextSeed),
  apply_all_maps(Rest, NextSeed, Location).

apply_all_maps_all_seeds(_, [], []).
apply_all_maps_all_seeds(Maps, [Seed|Rest], [Location|RestOfLocations]) :-
  apply_all_maps(Maps, Seed, Location),
  apply_all_maps_all_seeds(Maps, Rest, RestOfLocations).

lowest([X], X).
lowest([X | Rest], Lowest) :-
  lowest(Rest, RestLowest),
  (X < RestLowest -> Lowest = X ; Lowest = RestLowest).

first_part(AllMaps, Seeds) :-
  apply_all_maps_all_seeds(AllMaps, Seeds, Locations),
  lowest(Locations, Lowest),
  string_concat("First part:  ", Lowest, FirstPart),
  write(FirstPart),
  write("\n").

get_lowest_in_range_helper(_, 0, _, Lowest, Lowest).

get_lowest_in_range_helper(This, Range, Maps, LowestSoFar, Lowest) :-
  Range > 0,
  apply_all_maps(Maps, This, Location),
  Next is This + 1,
  NextRange is Range - 1,

  (Location < LowestSoFar -> NextLowest = Location ; NextLowest = LowestSoFar),
  get_lowest_in_range_helper(Next, NextRange, Maps, NextLowest, Lowest).

get_lowest_in_range(This, Range, Maps, Lowest) :-
  get_lowest_in_range_helper(This, Range, Maps, inf, Lowest).

get_lowest_in_ranges([], _, inf).
get_lowest_in_ranges([From, Range | Rest], Maps, Lowest) :-
  write("processing range\n"),
  get_lowest_in_range(From, Range, Maps, ThisLowest),
  get_lowest_in_ranges(Rest, Maps, NextLowest),
  (ThisLowest < NextLowest -> Lowest = ThisLowest ; Lowest = NextLowest).

list_to_ranges([], []).
list_to_ranges([From, Range | Rest], [range(From, Range) | RestOfRanges]) :-
  list_to_ranges(Rest, RestOfRanges).

get_lowest_in_range_maplist(Maps, range(From, Range), Lowest) :-
  format('processing range ~w ~w\n', [From, Range]),
  get_lowest_in_range(From, Range, Maps, Lowest),
  format('lowest in range ~w ~w is ~w\n', [From, Range, Lowest]).

halve_ranges([], []).
halve_ranges([range(From, Range) | Rest], [ NewRange1, NewRange2 | RestOfNewRanges]) :-
  HalfRange is Range // 2,
  Remainder is Range mod 2,
  NewRange1 = range(From, HalfRange),
  UpperStart is From + HalfRange,
  UpperRange is HalfRange + Remainder,
  NewRange2 = range(UpperStart, UpperRange),
  halve_ranges(Rest, RestOfNewRanges).

second_part(AllMaps, Seeds) :-
  list_to_ranges(Seeds, SeedsAsRanges),
  halve_ranges(SeedsAsRanges, HalvedRanges),
  concurrent_maplist(get_lowest_in_range_maplist(AllMaps), HalvedRanges, LowestInRanges),
  lowest(LowestInRanges, Lowest),
  string_concat("Second part: ", Lowest, SecondPart),
  write(SecondPart),
  write("\n").

compare_rules(Result, rule(From1, _, _), rule(From2, _, _)) :- compare(Result, From1, From2).

add_min_boundary(Map, MapWithMinBoundary) :-
  [rule(From, _, _) | _] = Map,
  (From = 0 ->
    MapWithMinBoundary = Map ;
    MapWithMinBoundary = [rule(0, 0, From) | Map]
  ).

add_max_boundary(Map, [NewRule | Map]) :-
  [rule(From, _, Range) | _] = Map,
  NewFrom is From + Range,
  NewRule = rule(NewFrom, NewFrom, _).

process_map(Map, ProcessedMap) :-
  predsort(compare_rules, Map, SortedMap),
  add_min_boundary(SortedMap, MapWithMinBoundary),
  reverse(MapWithMinBoundary, ReversedMap),
  add_max_boundary(ReversedMap, ProcessedMap).

process_all_maps([], []).
process_all_maps([Map|Rest], [ProcessedMap|RestOfProcessedMaps]) :-
  process_map(Map, ProcessedMap),
  process_all_maps(Rest, RestOfProcessedMaps).

main_ci :-
  read_file_to_string("inputs/input", File),
  split_string_into_lines(File, Lines),
  split_seed_and_maps(Lines, SeedLine, MapLines),
  string_concat("seeds: ", SeedlessSeedLine, SeedLine),
  split_string_into_nums(SeedlessSeedLine, Seeds),


  extract_maps(MapLines, SeedToSoilLines, SoilToFertilizerLines, FertilizerToWaterLines, WaterToLightLines, LightToTemperatureLines, TemperatureToHumidityLines, HumidityToLocationLines),
  AllMapLines = [SeedToSoilLines, SoilToFertilizerLines, FertilizerToWaterLines, WaterToLightLines, LightToTemperatureLines, TemperatureToHumidityLines, HumidityToLocationLines],
  parse_all_maps(AllMapLines, AllMaps),
  process_all_maps(AllMaps, ProcessedAllMaps),
  !,

  first_part(ProcessedAllMaps, Seeds),
  write("Second part takes too long to compute, so it's not run in CI\n"),
  halt.

main :-
  read_file_to_string("inputs/input", File),
  split_string_into_lines(File, Lines),
  split_seed_and_maps(Lines, SeedLine, MapLines),
  string_concat("seeds: ", SeedlessSeedLine, SeedLine),
  split_string_into_nums(SeedlessSeedLine, Seeds),


  extract_maps(MapLines, SeedToSoilLines, SoilToFertilizerLines, FertilizerToWaterLines, WaterToLightLines, LightToTemperatureLines, TemperatureToHumidityLines, HumidityToLocationLines),
  AllMapLines = [SeedToSoilLines, SoilToFertilizerLines, FertilizerToWaterLines, WaterToLightLines, LightToTemperatureLines, TemperatureToHumidityLines, HumidityToLocationLines],
  parse_all_maps(AllMapLines, AllMaps),
  process_all_maps(AllMaps, ProcessedAllMaps),
  !,

  first_part(ProcessedAllMaps, Seeds),
  !,
  second_part(ProcessedAllMaps, Seeds),
  halt.
