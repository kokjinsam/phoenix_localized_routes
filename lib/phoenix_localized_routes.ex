defmodule PhoenixLocalizedRoutes do
  @moduledoc false

  defmacro __using__(opts) do
    quote location: :keep do
      unquote(__MODULE__).__using__(__MODULE__, unquote(opts))
      import unquote(__MODULE__), only: :macros
    end
  end

  def __using__(mod, opts) do
    Module.put_attribute(mod, :locales, Keyword.fetch!(opts, :locales))
    Module.put_attribute(mod, :get_locale, Keyword.fetch!(opts, :get_locale))
  end

  defmacro sigil_q({:<<>>, _meta, _segments} = route, flags) do
    locales = attr!(__CALLER__, :locales)
    get_locale = attr!(__CALLER__, :get_locale)

    case_clauses =
      sigil_q_case_clauses(route, flags, locales)

    quote location: :keep do
      case unquote(get_locale).() do
        unquote(case_clauses)
      end
    end
  end

  defp interpolate_path(path, locale) do
    Macro.prewalk(path, fn
      segment when is_binary(segment) ->
        String.replace(segment, ":locale", locale)

      other ->
        other
    end)
  end

  defp attr!(env, name) do
    Module.get_attribute(env.module, name) || raise "expected @#{name} module attribute to be set"
  end

  defp sigil_q_case_clauses(route, flags, locales) do
    for locale <- locales do
      route_path = interpolate_path(route, locale)

      quote location: :keep do
        unquote(locale) -> sigil_p(unquote(route_path), unquote(flags))
      end
    end
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&hd/1)
  end
end
