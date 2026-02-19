defmodule TiptapPhoenix.MixProject do
  use Mix.Project

  @version "0.1.1"
  @source_url "https://github.com/wir-drei-digital/tiptap-phoenix"

  def project do
    [
      app: :tiptap_phoenix,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: "Tiptap rich-text editor integration for Phoenix LiveView",
      source_url: @source_url,
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:phoenix_live_view, "~> 1.0"},
      {:phoenix_html, "~> 4.0"},
      {:jason, "~> 1.2"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files:
        ~w(lib assets/js assets/css assets/package.json mix.exs README.md LICENSE .formatter.exs)
    ]
  end

  defp docs do
    [
      main: "TiptapPhoenix",
      source_ref: "v#{@version}"
    ]
  end
end
