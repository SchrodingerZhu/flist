defmodule FList.FNode do
  #implements for the tree node
  defstruct size: 0, branches: []
  def sizeL(list) do
    __sizeL(list, 0)
  end
  defp __sizeL([], cur), do: cur
  defp __sizeL([head | tail], cur) do
    __sizeL(tail, cur + head.size)
  end

  def wrap(x) do
    %FList.FNode{size: 1, branches: [x]}
  end

  def unwrap(%FList.FNode{size: s, branches: br}) when s == 1 do
    [ele] = br
    ele
  end

  def wraps(list) do
    %FList.FNode{size: sizeL(list), branches: list}
  end

  def unwraps(x) do
    x.branches
  end

  def splitNodesAt(0, [x]) do
    {[], x, []}
  end
  def splitNodesAt(i, [x | xs]) do
    cond do
      i < x.size ->
        {[], x, xs}
      true ->
        {xsp, y, ys} = splitNodesAt(i - x.size, xs)
        {[x | xsp], y, ys}
    end
  end
end

defmodule FList.FTree do
  #implements for the auxiliary tree
  def sizeT(:Empty), do: 0
  def sizeT({:Lf, a}), do: a.size
  def sizeT({:Tr, s, _, _, _}), do: s

  defp tree(f, :Empty, []) do
    List.foldr(f, :Empty, fn(x, acc) -> __cons(acc, x) end)
  end
  defp tree([], :Empty, r) do
    List.foldr(r, :Empty, fn(x, acc) -> __cons(acc, x) end)
  end
  defp tree([], m, r) do
    {f, mp} = __uncons(m)
    FList.FNode.unwraps(f) |> tree(mp, r)
  end
  defp tree(f, m, []) do
    {mp, r} = __unsnoc(m)
    tree(f, mp, FList.FNode.unwraps(r))
  end
  defp tree(f, m, r) do
    {:Tr, FList.FNode.sizeL(f) + sizeT(m) + FList.FNode.sizeL(r), f, m, r}
  end

  def cons(t, a), do: __cons(t, FList.FNode.wrap(a))
  defp __cons(:Empty, a), do: {:Lf, a}
  defp __cons({:Lf, b}, a), do: tree([a], :Empty, [b])
  defp __cons({:Tr, _, [b, c, d, e], m, r}, a) do
    tree([a, b], __cons(m, FList.FNode.wraps([c,d,e])), r)
  end
  defp __cons({:Tr, _, f, m, r}, a), do: tree([a | f], m, r)

  def uncons(ts) do
    {t, tsp} = __uncons(ts)
    {FList.FNode.unwrap(t), tsp}
  end
  defp __uncons({:Lf, a}), do: {a, :Empty}
  defp __uncons({:Tr, _, [a], :Empty, [b]}), do: {a, {:Lf, b}}
  defp __uncons({:Tr, _, [a], :Empty, [r | rs]}), do: {a, tree([r], :Empty, rs)}
  defp __uncons({:Tr, _, [a], m, r}) do
    {f, mp} = __uncons(m)
    {a, FList.FNode.unwraps(f) |> tree(mp, r)}
  end
  defp __uncons({:Tr, _, [a | f], m, r}), do: {a, tree(f, m, r)}

  def head(t) do
    {fst, _} = uncons(t)
    fst
  end

  def tail(t) do
    {_, snd} = uncons(t)
    snd
  end

  def snoc(t, a), do: __snoc(t, FList.FNode.wrap(a))
  defp __snoc(:Empty, a), do: {:Lf, a}
  defp __snoc({:Lf, a}, b), do: tree([a], :Empty, [b])
  defp __snoc({:Tr, _, f, m, [a, b, c, d]}, e) do
    tree(f, __snoc(m, FList.FNode.wraps([a, b, c])), [d, e])
  end
  defp __snoc({:Tr, _, f, m, r}, a), do: tree(f, m, r ++ [a])

  def unsnoc(ts) do
    {tsp, t} = __unsnoc(ts)
    {tsp, FList.FNode.unwrap(t)}
  end
  defp __unsnoc({:Lf, a}), do: {:Empty, a}
  defp __unsnoc({:Tr, _, [a], :Empty, [b]}), do: {{:Lf, a}, b}
  defp __unsnoc({:Tr, _, [head | tail], :Empty, [a]}) do
    thelast = List.last([head | tail])
    {tree(List.delete([head | tail], thelast), :Empty, [thelast]), a}
  end
  defp __unsnoc({:Tr, _, f, m, [a]}) do
    {mp, r} = __unsnoc(m)
    {tree(f, mp, FList.FNode.unwraps(r)), a}
  end
  defp __unsnoc({:Tr, _, f, m, r}) do
    thelast = List.last(r)
    {tree(f, m, List.delete(r, thelast)), thelast}
  end

  def last(t) do
    {_, snd} = unsnoc(t)
    snd
  end

  def init(t) do
    {fst, _} = unsnoc(t)
    fst
  end

  def concat(t1, t2) do
    merge(t1, [], t2)
  end

  defp merge(:Empty, ts, t2) do
    List.foldr(ts, t2, fn (x, acc) -> __cons(acc, x) end)
  end
  defp merge(t1, ts, :Empty) do
    List.foldl(ts, t1, fn (x, acc) -> __snoc(acc, x) end)
  end
  defp merge({:Lf, a}, ts, t2) do
    merge(:Empty, [a | ts], t2)
  end
  defp merge(t1, ts, {:Lf, a}) do
    merge(t1, ts ++ [a], :Empty)
  end
  defp merge({:Tr, s1, f1, m1, r1}, ts, {:Tr, s2, f2, m2, r2}) do
    {:Tr, s1 + s2 + FList.FNode.sizeL(ts), f1, merge(m1, nodes(r1 ++ ts ++ f2), m2), r2}
  end

  defp nodes([a, b]), do: [FList.FNode.wraps([a, b])]
  defp nodes([a, b, c]), do: [FList.FNode.wraps([a, b, c])]
  defp nodes([a, b, c, d]), do: [FList.FNode.wraps([a, b]), FList.FNode.wraps([c, d])]
  defp nodes([a ,b ,c | xs]), do: [FList.FNode.wraps([a, b, c]) | nodes(xs)]

  def splitAt({:Lf, x}, _) do
    {:Empty, x, :Empty}
  end
  def splitAt({:Tr, _, f, m, r}, i) do
    szf = FList.FNode.sizeL(f)
    szm = sizeT(m)
    cond do
      i < szf ->
        {xs, y, ys} = FList.FNode.splitNodesAt(i, f)
        {List.foldr(xs, :Empty, fn(x, acc) -> __cons(acc, x) end), y, tree(ys, m, r)}
      i < szf + szm ->
        {m1, t, m2} = splitAt(m, i - szf)
        {xs, y, ys} = FList.FNode.splitNodesAt(i - szf - sizeT(m1), FList.FNode.unwraps(t))
        {tree(f, m1, xs), y, tree(ys, m2, r)}
      true ->
        {xs, y, ys} = FList.FNode.splitNodesAt(i - szf - szm, r)
        {tree(f, m, xs), y, List.foldr(ys, :Empty, fn (x, acc) -> __cons(acc, x) end)}
    end
  end

  def getAt(t, i) do
    {_, x, _} = splitAt(t, i)
    FList.FNode.unwrap(x)
  end

  def extractAt(t, i) do
    {l, x, r} = splitAt(t, i)
    {FList.FNode.unwrap(x), concat(l, r)}
  end

  def setAt(t, i, x) do
    {l, _, r} = splitAt(t, i)
    concat(l, cons(r, x))
  end

  def moveToFront(t, i) do
    {a, tp} = extractAt(t, i)
    cons(tp, a)
  end

  def fromList(l) do
    List.foldr(l, :Empty, fn (x, acc) -> cons(acc, x) end)
  end

  def toList(:Empty) do
    []
  end
  def toList(t) do
    [head(t) | (tail(t) |> toList)]
  end
end


defmodule FList.FTest do
  #the test module, unfinished yet
  def prop_cons(xs) do
    xs == FList.FTree.fromList(xs) |> FList.FTree.toList()
  end

  def prop_snoc(xs) do
    xs == xs |> List.foldl(:Empty, fn (x, acc) -> FList.FTree.snoc(acc, x) end) |> FList.FTree.toList()
  end

  def prop_concat(xs, ys) do
    (xs ++ ys) == FList.FTree.concat(FList.FTree.fromList(xs), FList.FTree.fromList(ys)) |> FList.FTree.toList()
  end

  def prop_lookup(xs, i) do
    if 0 <= i && i < length(xs) do
      FList.FTree.getAt(FList.FTree.fromList(xs), i) == Enum.fetch!(xs, i)
    else
      :BAD_INDEX
    end
  end

  def prop_update(xs, i, y) do
    if 0 <= i && i < length(xs) do
      FList.FTree.fromList(xs) |> FList.FTree.setAt(i, y) |> FList.FTree.toList == List.update_at(xs, i, fn _ -> y end) 
    else
      :BAD_INDEX
    end
  end

  def prop_mtf(xs, i) do
    if 0 <= i && i < length(xs) do
      a = FList.FTree.fromList(xs) |> FList.FTree.moveToFront(i) |> FList.FTree.toList
      {_, b} = List.pop_at(xs, i)
      a == [Enum.fetch!(xs, i) | b]
    else
      :BAD_INDEX
    end
  end

  
end

defmodule FList do
   #the wrapper for the fingertree, with incompleted protocols support
   defstruct tree: :Empty
   def new(t \\ :Empty), do: %FList{tree: t}

   #operations for the front of the list
   def cons(list, x), do: FList.FTree.cons(list.tree, x) |> new()
   def uncons(list) do
     {x, t} = FList.FTree.uncons(list.tree)
     {x, new(t)}
   end
   def head(list) do
     FList.FTree.head(list.tree)
   end
   def tail(list) do
     list.tree |> FList.FTree.tail() |> new()
   end

   #operations for the back of the list
   def snoc(list, x), do: FList.FTree.snoc(list.tree, x) |> new()
   def unsnoc(list) do
     {t, x} = FList.FTree.unsnoc(list.tree)
     {new(t), x}
   end
   def last(list) do
     FList.FTree.last(list.tree)
   end
   def init(list) do
     list.tree |> FList.FTree.init() |> new()
   end

   #other operations
   def size(list), do: FList.FTree.sizeT(list.tree)
   def concat(a, b) do
     FList.FTree.concat(a.tree, b.tree) |> new()
   end
   def splitAt(list, x) do
     {a, ele, b} = FList.FTree.splitAt(list.tree, x)
     {new(a), ele, new(b)}
   end
   def getAt(list, x) do
     FList.FTree.getAt(list.tree, x)
   end
   def extractAt(list, x) do
     {ele, t} = FList.FTree.extractAt(list.tree, x)
     {ele, new(t)}
   end
   def setAt(list, x, ele) do
     list.tree |> FList.FTree.setAt(x, ele) |> new()
   end
   def moveToFront(list, x) do
     list.tree |> FList.FTree.moveToFront(x) |> new()
   end
   def fromList(originalList) do
     originalList |> FList.FTree.fromList() |> new()
   end
   def toList(list) do
     list.tree |> FList.FTree.toList()
   end


end

defimpl Inspect, for: FList do
  def inspect(tree, _opts \\ nil) do
    "#FList<" <> (tree |> FList.toList() |> Kernel.inspect()) <> ">"
  end
end

defimpl Enumerable, for: FList do
  def count(t) do
    {:ok, FList.size(t)}
  end
  def at(t, index) do
    {:ok, FList.getAt(t, index)}
  end
  def member?(t, term) do
    {:error, __MODULE__}
  end
  def reduce(_, {:halt, acc}, _fun) do
    {:halted, acc}
  end
  def reduce(list, {:suspend, acc}, fun) do
    {:suspended, acc, &reduce(list, &1, fun)}
  end
  def reduce(list, {:cont, acc}, fun) do
    cond do
      list.tree == :Empty -> {:done, acc}
      true -> {head, tail} = FList.uncons(list)
              reduce(tail, fun.(head, acc), fun)
    end
  end
end

defimpl Collectable, for: FList do
  def into(original) do
    {original, fn
      list, {:cont, x} -> FList.snoc(list, x)
      list, :done -> list
      _, :halt -> :ok
    end}
  end
end


