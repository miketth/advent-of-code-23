defmodule Aoc23 do
  def start(_type, _args) do
    First.solve()
    First.solve_plus()
    {:ok, self()}
  end
end
