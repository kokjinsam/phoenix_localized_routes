# PhoenixLocalizedRoutes

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `phoenix_localized_routes` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:phoenix_localized_routes, "~> 0.1.0"}
  ]
end
```

## Usage

1. Define a `localized_routes` function in your web module.

```elixir
defmodule YourWeb do
  def localized_routes do
    quote do
      unquote(__MODULE__).load_module_attributes(__MODULE__)

      import YourWeb, only: [get_page_locale: 0]

      use PhoenixLocalizedRoutes,
        locales: ["en-us"],
        get_locale: &get_page_locale/0
    end
  end

  def get_page_locale do
    Process.get(@page_locale_key)
  end
end
```

2. Include the function in your `html_helpers`.

```elixir
defp html_helpers do
  quote do
    # ...other code...

    # Routes generation with the ~q sigil
    unquote(localized_routes())
  end
end
```

3. Use the `~q` sigil in your templates:

```heex
<.link href={~q"/:locale/pricing"}>
  Pricing
</.link>
```
