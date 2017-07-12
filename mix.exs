defmodule FList.Mixfile do
  use Mix.Project

  def project do
    [app: :flist,
     version: "0.2.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     name: "flist",
     licenses: ["MIT"],
     maintainers: ["SchrodingerZhu(朱一帆)"],
     links: %{"SchrodingerZhu's GitHub" => "https://github.com/SchrodingerZhu"},
     source_url: "https://github.com/SchrodingerZhu/flist",
     description: description(),
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    []
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:ex_doc, "~> 0.14", only: :dev, runtime: false}]
  end
  defp description do
    """
   FList a functional list implement using the efficient data structure of fingertree. Any operation in the front and the back is amortized O(1) and the operations involved randomly visiting are O(log n).
   """
  end
  defp package do
    [
     name: :flist,
     licenses: ["MIT"],
     maintainers: ["SchrodingerZhu(朱一帆)"],
     links: %{"SchrodingerZhu's GitHub" => "https://github.com/SchrodingerZhu"},
     source_url: "https://github.com/SchrodingerZhu/flist",
     description: description(),
     deps: deps()]
  end
end
