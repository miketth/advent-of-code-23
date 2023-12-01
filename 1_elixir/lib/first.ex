defmodule First do
  def solve() do
    File.stream!("inputs/first")
    |> Enum.map(&process_line/1)
    |> Enum.sum()
    |> IO.puts()
  end

  def process_line(line) do
    numbers = Regex.replace(~r/[^\d]/, line, "")
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)

    [ first | _ ] = numbers
    [ last | _ ] = numbers |> Enum.reverse()

    first*10 + last
  end

  def solve_plus() do
    File.stream!("inputs/first")
    |> Enum.map(&process_line_plus/1)
    |> Enum.sum()
    |> IO.puts()
  end

  def process_line_plus(line) do
    unspelled_from_front = unspell_from_front(line)
    unspelled_from_back = unspell_from_back(line)
    numbers_from_front =
      Regex.replace(~r/[^\d]/, unspelled_from_front, "")
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
    numbers_from_back =
      Regex.replace(~r/[^\d]/, unspelled_from_back, "")
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)

    [ first | _ ] = numbers_from_front
    [ last | _ ] = numbers_from_back |> Enum.reverse()

    first*10 + last
  end
  
  

  def unspell_from_front(line) do unspell_from_front("", line) end
  def unspell_from_front(processed, "") do processed end
  def unspell_from_front(processed, <<next_char::utf8, rest::binary>>) do
    to_process = processed <> <<next_char::utf8>>
    new_processed = spelled_to_num(to_process)
    unspell_from_front(new_processed, rest)
  end

  def unspell_from_back(line) do unspell_from_back("", line) end
  def unspell_from_back(processed, "") do processed end
  def unspell_from_back(processed, line) do
    [ _ | [ rest | [last_char] ]] = Regex.run(~r/^(.*)(.)$/, line)
    to_process = last_char <> processed
    new_processed = spelled_to_num(to_process)
    unspell_from_back(new_processed, rest)
  end


  def spelled_to_num(line) do
    line
    |> String.replace("one", "1")
    |> String.replace("two", "2")
    |> String.replace("three", "3")
    |> String.replace("four", "4")
    |> String.replace("five", "5")
    |> String.replace("six", "6")
    |> String.replace("seven", "7")
    |> String.replace("eight", "8")
    |> String.replace("nine", "9")
  end

end
