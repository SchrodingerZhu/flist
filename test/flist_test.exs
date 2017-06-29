defmodule FListTest do
  use ExUnit.Case
  doctest FList
  def initData() do
    Stream.repeatedly(fn -> Enum.random(1..100000) end) |> Enum.take(100000)
  end
  
  test "Test fromList and to List" do
    data = initData()
    assert data == (data |> FList.fromList() |> FList.toList())
  end

  test "Test snoc" do
    data = initData()
    assert data |> List.foldl(FList.new(), fn (x, acc) -> FList.snoc(acc, x) end) |> FList.toList()
  end

  test "Test concat" do
    x = initData()
    y = initData()
    assert (x ++ y) == FList.concat(FList.fromList(x), FList.fromList(y)) |> FList.toList()
  end
  test "Test lookup" do
	  data = initData()
	  l = FList.fromList(data)
    result= 
       Stream.repeatedly(fn -> Enum.random(0..99999) end)
	     |> Enum.take(100)
	     |> Enum.map(fn a -> Enum.fetch!(data, a) == FList.getAt(l, a) end)
	     |> List.foldl(true, fn (x, acc) -> x && acc end)
    assert result 
  end

  test "Test update" do
  	data = initData()
    l = FList.fromList(data)
	  {nl, fl} = 
        Stream.repeatedly(fn -> {Enum.random(0..99999), Enum.random(1..100000)} end)
	      |> Enum.take(100)
        |> List.foldl({data, l}, fn ({i, x}, {a, b}) -> {List.update_at(a, i, fn _ -> x end), FList.setAt(b, i, x)} end)
	  assert nl == FList.toList(fl)
  end
  test "Test moveToFront"
	   data = initData()
     l = FList.fromList(data)	  
	   result = 
        Stream.repeatedly(fn -> Enum.random(0..99999) end)
        |> Enum.take(100)
	      |> Enum.map(fn a -> (l |> FList.moveToFront(a) |> FList.head()) A== Enum.fetch!(data, a) end)
	      |> List.foldl(true, fn (x, acc) -> x && acc end)
	   assert result
  end
  
end
  
