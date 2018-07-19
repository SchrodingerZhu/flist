defmodule FListTest do
  use ExUnit.Case
  doctest FList

  defp init_data(n \\ 100_000) do
    Stream.repeatedly(fn -> Enum.random(1..100_000) end) |> Enum.take(n)
  end

  defp mtf(list, i) do
    {a, b} = List.pop_at(list, i)
    [a | b]
  end

  test "Test from_list and to List" do
    data = init_data()
    assert data == data |> FList.from_list() |> FList.to_list()
  end

  test "Test snoc" do
    data = init_data()
    assert data |> List.foldl(FList.new(), fn x, acc -> FList.snoc(acc, x) end) |> FList.to_list()
  end

  test "Test concat" do
    x = init_data()
    y = init_data()
    assert x ++ y == FList.concat(FList.from_list(x), FList.from_list(y)) |> FList.to_list()
  end

  test "Test lookup" do
    data = init_data()
    l = FList.from_list(data)

    result =
      Stream.repeatedly(fn -> Enum.random(0..99999) end)
      |> Enum.take(100)
      |> Enum.map(fn a -> Enum.fetch!(data, a) == FList.get_at(l, a) end)
      |> List.foldl(true, fn x, acc -> x && acc end)

    assert result
  end

  test "Test update" do
    data = init_data()
    l = FList.from_list(data)

    {nl, fl} =
      Stream.repeatedly(fn -> {Enum.random(0..99999), Enum.random(1..100_000)} end)
      |> Enum.take(100)
      |> List.foldl({data, l}, fn {i, x}, {a, b} ->
        {List.update_at(a, i, fn _ -> x end), FList.set_at(b, i, x)}
      end)

    assert nl == FList.to_list(fl)
  end

  test "Test move_to_front" do
    data = init_data(1000)
    l = FList.from_list(data)

    {nl, fl} =
      Stream.repeatedly(fn -> Enum.random(0..999) end)
      |> Enum.take(100)
      |> List.foldl({data, l}, fn i, {a, b} -> {mtf(a, i), FList.move_to_front(b, i)} end)

    assert nl == FList.to_list(fl)
  end

  test "Test slice" do
    data = init_data(10000)
    list = FList.from_list(data)

    res =
      Stream.repeatedly(fn -> {Enum.random(0..9999), Enum.random(0..999)} end)
      |> Enum.take(1000)
      |> Enum.map(fn {x, y} -> Enum.slice(data, x, y) == Enum.slice(list, x, y) end)
      |> Enum.reduce(true, &(&1 && &2))

    assert res
  end
end
