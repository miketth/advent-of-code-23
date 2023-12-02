defmodule Aoc23 do
  def start(_type, _args) do
    first = First.solve()
    IO.puts("First part: #{first}")
    plus = First.solve_plus()
    IO.puts("Second part: #{plus}")
    {:ok, self()}
  end
end
