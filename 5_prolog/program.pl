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

intersect(rule(RuleFrom, _, RuleLen), range(RangeFrom, RangeLen), Intersecting, NonIntersecting) :-
  (RuleLen = inf -> RuleEnd = inf; RuleEnd is RuleFrom + RuleLen - 1),
  RangeEnd is RangeFrom + RangeLen - 1,

  IntersectStart is max(RuleFrom, RangeFrom),
  IntersectEnd is min(RuleEnd, RangeEnd),

  (IntersectStart =< IntersectEnd ->
    (
      % intersecting
      IntersectLen is IntersectEnd - IntersectStart + 1,
      Intersecting = [ range(IntersectStart, IntersectLen) ],

      BeforeLen is min(IntersectStart - RangeFrom, RangeLen),
      Before = range(RangeFrom, BeforeLen),

      AfterLen is min(RangeEnd - IntersectEnd, RangeLen),
      After = range(IntersectEnd, AfterLen),

      ((BeforeLen > 0, AfterLen > 0) -> NonIntersecting = [Before, After];
        ((BeforeLen > 0, AfterLen =< 0) -> NonIntersecting = [Before];
          ((BeforeLen =< 0, AfterLen > 0) -> NonIntersecting = [After];
            NonIntersecting = []
          )
        )
      )
    );
    Intersecting = [],
    NonIntersecting = [range(RangeFrom, RangeLen)]
  ).

do_apply(_, [], []).
do_apply(Rule, [range(RangeFrom, RangeLen) | Ranges], [range(NewRangeFrom, RangeLen) | NewRanges]) :-
  rule(RuleFrom, RuleTo, _) = Rule,
  Delta is RuleTo - RuleFrom,
  NewRangeFrom is RangeFrom + Delta,
  do_apply(Rule, Ranges, NewRanges).

apply_rules_ranges(_, [], []).
apply_rules_ranges(Rules, [Range | Ranges], OutRanges) :-
  apply_rules(Rules, Range, NewRanges),
  append(NewRanges, RestOfNewRanges, OutRanges),
  apply_rules_ranges(Rules, Ranges, RestOfNewRanges), !.

% for all rules: apply to appropriate part of range, mayhaps none at all, produce new range(s).
apply_rules([], Range, [Range]).
apply_rules([Rule|Rules], Range, NewRanges) :-
  intersect(Rule, Range, Intersecting, NonIntersecting),
  % apply this rule on intersection
  do_apply(Rule, Intersecting, Applied), !,

  append(Applied, RestApplied, NewRanges),
  % apply rest of rules on non-intersecting ranges
  apply_rules_ranges(Rules, NonIntersecting, RestApplied).


apply_maps_ranges([], Ranges, Ranges).
apply_maps_ranges([Rules | Maps], Ranges, OutRanges) :-
  apply_rules_ranges(Rules, Ranges, Applied),
  apply_maps_ranges(Maps, Applied, OutRanges).

seeds_to_ranges([], []).
seeds_to_ranges([Seed | Seeds], [Range | Ranges]) :-
  Range = range(Seed, 1),
  seeds_to_ranges(Seeds, Ranges).

lowest_range_helper([], Lowest, Lowest).
lowest_range_helper([range(Start, _) | Ranges], LowestSoFar, Lowest) :-
  (Start < LowestSoFar -> NewLowest = Start; NewLowest = LowestSoFar),
  lowest_range_helper(Ranges, NewLowest, Lowest).

lowest_range(Ranges, Lowest) :- lowest_range_helper(Ranges, inf, Lowest).

first_part(AllMaps, Seeds) :-
  seeds_to_ranges(Seeds, Ranges),
  apply_maps_ranges(AllMaps, Ranges, AppliedRanges),
  lowest_range(AppliedRanges, Lowest),
  string_concat("First part:  ", Lowest, FirstPart),
  write(FirstPart),
  write("\n").

list_to_ranges([], []).
list_to_ranges([From, Range | Rest], [range(From, Range) | RestOfRanges]) :-
  list_to_ranges(Rest, RestOfRanges).

second_part(AllMaps, Seeds) :-
  list_to_ranges(Seeds, Ranges),
  apply_maps_ranges(AllMaps, Ranges, Applied),
  lowest_range(Applied, Lowest),
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
  NewRule = rule(NewFrom, NewFrom, inf).

process_map(Map, ProcessedMap) :-
  predsort(compare_rules, Map, SortedMap),
  add_min_boundary(SortedMap, MapWithMinBoundary),
  reverse(MapWithMinBoundary, ReversedMap),
  add_max_boundary(ReversedMap, ProcessedMap).

process_all_maps([], []).
process_all_maps([Map|Rest], [ProcessedMap|RestOfProcessedMaps]) :-
  process_map(Map, ProcessedMap),
  process_all_maps(Rest, RestOfProcessedMaps).

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
