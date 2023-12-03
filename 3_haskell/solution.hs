import System.IO
import Data.Char (isDigit)

readInput :: IO [String]
readInput = do
  content <- readFile "inputs/input"
  return (lines content)

processLine :: String -> Int -> [(Int, [(Int, Int)])]
processLine line y = processLineNum line Nothing 0 y

processLineNum :: String -> Maybe (Int, [(Int, Int)]) -> Int -> Int -> [(Int, [(Int, Int)])]
-- end of line
processLineNum [] Nothing _ _ = []
processLineNum [] (Just something) _ _ = [something]

-- repeated .
processLineNum ('.':rest) Nothing x y = processLineNum rest Nothing (x + 1) y

-- end of number
processLineNum ('.':rest) (Just num) x y = (num : processLineNum rest Nothing (x + 1) y)

-- new number or symbol
processLineNum (char:rest) Nothing x y =
  let num = if isDigit char
            then let n = read [char] :: Int -- number starts
                 in Just(n, (neighbors (x, y)))
            else Nothing -- symbol
  in processLineNum rest num (x + 1) y

-- continue number or symbol
processLineNum (char:rest) (Just (n_prev, pos)) x y =
  let num = if isDigit char
            then let n = read [char] :: Int -- number continues
                 in Just((n_prev*10+n), pos ++ (neighbors (x, y)))
            else Nothing -- symbol, number ends
      to_append = if isDigit char
                  then []
                  else [(n_prev, pos)]
  in to_append ++ (processLineNum rest num (x + 1) y)


neighbors :: (Int, Int) -> [(Int, Int)]
neighbors (x, y) = [(x - 1, y - 1), (x, y - 1), (x + 1, y - 1),
                    (x - 1, y),                 (x + 1, y),
                    (x - 1, y + 1), (x, y + 1), (x + 1, y + 1)]

processLines :: [String] -> [(Int, [(Int, Int)])]
processLines lines = processLinesNum lines 0

processLinesNum :: [String] -> Int -> [(Int, [(Int, Int)])]
processLinesNum [] _ = []
processLinesNum (line:rest) y =
  let processed = processLine line y
      more = processLinesNum rest (y + 1)
  in processed ++ more


findSymbolsInLineNum :: String -> Int -> Int -> [(Char, (Int, Int))]
findSymbolsInLineNum [] _ _ = []
findSymbolsInLineNum ('.':rest) x y = findSymbolsInLineNum rest (x + 1) y
findSymbolsInLineNum (char:rest) x y =
  let more = findSymbolsInLineNum rest (x + 1) y
  in if isDigit char
     then more
     else ((char, (x, y)) : more)

findSymbolsInLine :: String -> Int -> [(Char, (Int, Int))]
findSymbolsInLine line y = findSymbolsInLineNum line 0 y

findSymbols :: [String] -> [(Char, (Int, Int))]
findSymbols lines = findSymbolsNum lines 0

findSymbolsNum :: [String] -> Int -> [(Char, (Int, Int))]
findSymbolsNum [] _ = []
findSymbolsNum (line:rest) y =
  let symbols = findSymbolsInLine line y
      more = findSymbolsNum rest (y + 1)
  in symbols ++ more


doesNumberHaveSymbolMatch :: (Int, [(Int, Int)]) -> [(Int, Int)] -> Bool
doesNumberHaveSymbolMatch (n, pos) symbols =
  let matches = filter (\(x, y) -> elem (x, y) pos) symbols
  in length matches > 0

filterNumbersWithSymbolMatches :: [(Int, [(Int, Int)])] -> [(Int, Int)] -> [(Int, [(Int, Int)])]
filterNumbersWithSymbolMatches numbers symbols =
  filter (\(n, pos) -> doesNumberHaveSymbolMatch (n, pos) symbols) numbers

mapNumberToInt :: (Int, [(Int, Int)]) -> Int
mapNumberToInt (n, _) = n

mapNumbersToInts :: [(Int, [(Int, Int)])] -> [Int]
mapNumbersToInts numbers = map (\(n, _) -> n) numbers

symbolsToCoords :: [(Char, (Int, Int))] -> [(Int, Int)]
symbolsToCoords symbols = map (\(_, pos) -> pos) symbols

main :: IO()
main = do
  input <- readInput
  let processed = processLines input
  let symbols = findSymbols input
  let symbolsCoords = symbolsToCoords symbols
  let filtered = filterNumbersWithSymbolMatches processed symbolsCoords
  let mapped = mapNumbersToInts filtered
  let sum = foldl (+) 0 mapped
  print sum
