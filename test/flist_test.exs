defmodule FListTest do
  use ExUnit.Case
  doctest FList
  def initData() do
    Stream.repeatedly(fn -> Enum.random(1..100000) end) |> Enum.take(100000)
  end
  
  test "Test fromList" do
    data = initData()
    data == data |> FList.fromList() |> FList.toList()
  end
  
end
  
