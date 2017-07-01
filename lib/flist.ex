defmodule FList.FNode do
  @moduledoc """
  This module defines the fingertree nodes and the operations used for the xnodes.
  If you needn't add your own functions to FList, you should not use the methods provided in this module directly.
  """

  @typedoc """
  FList.FNode.t is the type stands for the fingertree node. 
  """
  defstruct size: 0, branches: []
  @type t :: %FList.FNode{size: non_neg_integer, branches: list}
  

  @doc """
  Return the size of a list that contains some the nodes.
  """
  @spec sizeL([t]) :: non_neg_integer

  def sizeL(list) do
    __sizeL(list, 0)
  end
  defp __sizeL([], cur), do: cur
  defp __sizeL([head | tail], cur) do
    __sizeL(tail, cur + head.size)
  end

  @doc """
  Make a tree node from a single element.
  """
  @spec wrap(any) :: t
  def wrap(x) do
    %FList.FNode{size: 1, branches: [x]}
  end

  @doc """
  Get the element from a node of size == 1.
  """
  @spec unwrap(t) :: any
  def unwrap(%FList.FNode{size: s, branches: br}) when s == 1 do
    [ele] = br
    ele
  end

  @doc """
  Make a tree node from a list of elements.
  """
  @spec wraps(list) :: t
  def wraps(list) do
    %FList.FNode{size: sizeL(list), branches: list}
  end

  @doc """
  Get the list of branches from a node.
  """
  @spec unwraps(t) :: list
  def unwraps(x) do
    x.branches
  end

  @doc """
  Split a list of nodes at the pointed position.
  """
  @spec splitNodesAt(non_neg_integer, [t]) :: {[t], t, [t]}
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
  @moduledoc """
  In this module, we define the bottom data structure fingertree, which is used by FList. Similarly, if you are not to customize your own FingerTree wrapper, it is recommended to used the methods defined in the module of FList rather that those defined here.
  """
  @typedoc """
  FList.FTree.t stands for the data structure of fingertree.
  """
  @type t :: :Empty | {:Lf, FList.FNode.t} | {:Tr, non_neg_integer, [FList.FNode.t], t, [FList.FNode.t]}

  @doc """
  Reture the size of a tree.
  """
  @spec sizeT(t) :: non_neg_integer

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

  @doc """
  Add an element to the front.
  """
  @spec cons(t, any) :: t
  def cons(t, a), do: __cons(t, FList.FNode.wrap(a))
  defp __cons(:Empty, a), do: {:Lf, a}
  defp __cons({:Lf, b}, a), do: tree([a], :Empty, [b])
  defp __cons({:Tr, _, [b, c, d, e], m, r}, a) do
    tree([a, b], __cons(m, FList.FNode.wraps([c,d,e])), r)
  end
  defp __cons({:Tr, _, f, m, r}, a), do: tree([a | f], m, r)
  @doc """
  Pop the front element and return a tuple.
  """
  @spec uncons(t) :: {any, t}
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
  @doc """
  Get the first element.
  """
  @spec head(t) :: any
  def head(t) do
    {fst, _} = uncons(t)
    fst
  end
  @doc """
  Get the list tree with the front element popped.
  """
  @spec tail(t) :: t
  def tail(t) do
    {_, snd} = uncons(t)
    snd
  end

  @doc """
  Add an element to the back.
  """
  @spec snoc(t, any) :: t
  def snoc(t, a), do: __snoc(t, FList.FNode.wrap(a))
  defp __snoc(:Empty, a), do: {:Lf, a}
  defp __snoc({:Lf, a}, b), do: tree([a], :Empty, [b])
  defp __snoc({:Tr, _, f, m, [a, b, c, d]}, e) do
    tree(f, __snoc(m, FList.FNode.wraps([a, b, c])), [d, e])
  end
  defp __snoc({:Tr, _, f, m, r}, a), do: tree(f, m, r ++ [a])

  @doc """
  Pop the element in the back and return a tuple.
  """
  @spec unsnoc(t) :: {t, any}
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
  @doc """
  Get the last element. 
  """
  @spec last(t) :: any
  def last(t) do
    {_, snd} = unsnoc(t)
    snd
  end
  @doc """
  Get the list tree with the back element popped.
  """
  @spec init(t) :: t
  def init(t) do
    {fst, _} = unsnoc(t)
    fst
  end
  @doc """
  Concat two list tree.
  """
  @spec concat(t, t) :: t
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

  @doc """
  Split the list tree at the pointed position.
  """
  @spec splitAt(t, non_neg_integer) :: {t, any, t}
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
  @doc """
  Get the element from a tree at the pointed position.
  """
  @spec getAt(t, non_neg_integer) :: any
  def getAt(t, i) do
    {_, x, _} = splitAt(t, i)
    FList.FNode.unwrap(x)
  end
  @doc """
  Get a new tree with the element at the pointed position deleted.
  """
  @spec extractAt(t, non_neg_integer) :: t
  def extractAt(t, i) do
    {l, x, r} = splitAt(t, i)
    {FList.FNode.unwrap(x), concat(l, r)}
  end
  @doc """
  Update the element at the pointed position.
  """
  @spec setAt(t, non_neg_integer, any) :: t
  def setAt(t, i, x) do
    {l, _, r} = splitAt(t, i)
    concat(l, cons(r, x))
  end
  @doc """
  Get a new list tree with the element at the pointed position moved to the front.
  """
  @spec moveToFront(t, non_neg_integer) :: t
  def moveToFront(t, i) do
    {a, tp} = extractAt(t, i)
    cons(tp, a)
  end
  @doc """
  Generate a tree from a list
  """
  @spec fromList(list) :: t
  def fromList(l) do
    List.foldr(l, :Empty, fn (x, acc) -> cons(acc, x) end)
  end
  @doc """
  Turn the given tree to a normal list.
  """
  @spec toList(t) :: list
  def toList(:Empty) do
    []
  end
  def toList(t) do
    [head(t) | (tail(t) |> toList)]
  end
end

defmodule FList do
   @moduledoc """
   FList a functional list implement using the efficient data structure of fingertree. Any operation in the front and the back is amortized O(1) and the operations involved randomly visiting are O(log n).
   We complete this work with some reference source files in Haskell from the project of [AlgoXY](https://github.com/liuxinyu95/AlgoXY/blob/algoxy/datastruct/elementary/sequence/src/FingerTree.hs), here we need to show our acknowledging.
   Now, FList can partly support the protocol of Enumerable and the protocol of Collectable. However, as there still remains a long way to go, the time complexity of these protocals are not assured. Therefore, if you need the assurance now, you'd better use the methods provided below. These methods will be reserved in the future though the protocols are getting better implements in the next version of this module.
   FList can be inspected in a pretty-looking way, which is shown below:
   ## Examples

       iex> [1, 2, 3, 4] |> FList.fromList()
       #FList<[1, 2, 3, 4]>

   You can run `mix test` first to check whether the implement is working well.
   """

   @typedoc """
   FList.t stands for the FList.
   """
   defstruct tree: :Empty
   @type t :: %FList{tree: FList.FTree.t}

   @doc """
   Generate a FList from the given FTree. If the tree is not provided, a empty list will be generated. 
   """
   @spec new(FList.FTree.t) :: t
   def new(t \\ :Empty), do: %FList{tree: t}

   @doc """
   Add a new element to the front.
   ## Examples

       iex> FList.new() |> FList.cons(0)
       #FList<[0]>

   """
   @spec cons(t, any) :: t
   def cons(list, x), do: FList.FTree.cons(list.tree, x) |> new()

   @doc """
   Pop the front element, and then return a tuple.
   """
   @spec uncons(t) :: {any, t}

   def uncons(list) do
     {x, t} = FList.FTree.uncons(list.tree)
     {x, new(t)}
   end

   @doc """
   Get the front element.
   """
   @spec head(t) :: any
   def head(list) do
     FList.FTree.head(list.tree)
   end
   @doc """
   Get a new list without the front elemeny.
   """
   @spec tail(t) :: t
   def tail(list) do
     list.tree |> FList.FTree.tail() |> new()
   end

   @doc """
   Add a new element to the back.
   """
   @spec snoc(t, any) :: t
   def snoc(list, x), do: FList.FTree.snoc(list.tree, x) |> new()

   @doc """
   Pop the back element, and then return a tuple.
   """
   @spec unsnoc(t) :: {t, any}
   def unsnoc(list) do
     {t, x} = FList.FTree.unsnoc(list.tree)
     {new(t), x}
   end

   @doc """
   Get the back element.
   """
   @spec last(t) :: any
   def last(list) do
     FList.FTree.last(list.tree)
   end
   @doc """
   Get a new list without the back element.
   """
   @spec init(t) :: t
   def init(list) do
     list.tree |> FList.FTree.init() |> new()
   end

   @doc """
   Get the size of a FList.
   """
   @spec size(t) :: non_neg_integer
   def size(list), do: FList.FTree.sizeT(list.tree)

   @doc """
   Concat two FLists.
   """
   @spec concat(t, t) :: t
   def concat(a, b) do
     FList.FTree.concat(a.tree, b.tree) |> new()
   end
   @doc """
   Split a FList at the pointed position.
   """
   @spec splitAt(t, non_neg_integer) :: {t, any, t}
   def splitAt(list, x) do
     {a, ele, b} = FList.FTree.splitAt(list.tree, x)
     {new(a), ele, new(b)}
   end
   @doc """
   Get the element at the pointed position from a FList.
   """
   @spec getAt(t, non_neg_integer) :: any
   def getAt(list, x) do
     FList.FTree.getAt(list.tree, x)
   end
   @doc """
   Get a new list without the element at the pointed position. 
   """
   @spec extractAt(t, non_neg_integer) :: t
   def extractAt(list, x) do
     {ele, t} = FList.FTree.extractAt(list.tree, x)
     {ele, new(t)}
   end
   @doc """
   Update the value of the element at the pointed position.
   """
   @spec setAt(t, non_neg_integer, any) :: t
   def setAt(list, x, ele) do
     list.tree |> FList.FTree.setAt(x, ele) |> new()
   end
   @doc """
   Get a new list with the element at the pointed position moved to the front.
   """
   @spec moveToFront(t, non_neg_integer) :: t
   def moveToFront(list, x) do
     list.tree |> FList.FTree.moveToFront(x) |> new()
   end
   @doc """
   Generate a FList from the given normal list.
   """
   @spec fromList(list) :: t
   def fromList(originalList) do
     originalList |> FList.FTree.fromList() |> new()
   end
   @doc """
   Turn a FList into a normal list.
   """
   @spec toList(t) :: list
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
  def member?(_t, _term) do
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
