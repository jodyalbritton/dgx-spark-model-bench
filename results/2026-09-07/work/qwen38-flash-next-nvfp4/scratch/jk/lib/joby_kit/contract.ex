defmodule JobyKit.Contract do
  @moduledoc """
  The universal JobyKit contract content: the 5-step build order, the
  3-layer module taxonomy, and the wrapper-contract checklist.

  This module is host-agnostic. The phrasing belongs to the package, not
  the consumer — every JobyKit-installed app gets the same agentic
  contract surface.
  """

  @build_order [
    %{
      step: 1,
      tone: :neutral,
      title: "Domain composite?",
      description:
        "Use it. Lives in a domain-scoped component module in this app. Surfaces on the custom-designs page."
    },
    %{
      step: 2,
      tone: :neutral,
      title: "Generic composite?",
      description:
        "Use it. Multi-primitive pattern reused across domains in this app. Surfaces on the custom-designs page."
    },
    %{
      step: 3,
      tone: :neutral,
      title: "Core wrapper?",
      description:
        "Use it. One wrapper per daisyUI primitive, defined in core_components. Surfaces here on the kit page."
    },
    %{
      step: 4,
      tone: :warning,
      title: "daisyUI primitive?",
      description:
        "Wrap it as a core component first, then use the wrapper. See the daisyUI catalogue at the bottom of this page."
    },
    %{
      step: 5,
      tone: :error,
      title: "Build from tokens.",
      description:
        "Tailwind + theme tokens only. Expose the result as a core wrapper (kit page) or generic/domain composite (custom-designs page) and register it in the manifest."
    }
  ]

  @rules [
    %{
      key: "attrs",
      title: "Declare every prop with attr.",
      body:
        "Use values: constraints for variant/tone/size enums. The prop signature shown on the page is generated from these declarations."
    },
    %{
      key: "data-component",
      title: "Carry data-component on the root element.",
      body:
        "Format: \"App.Module.function\" — the canonical inspect-style identifier of the function component. Required for traceability, agent inspection, and tests."
    },
    %{
      key: "rest-global",
      title: "Accept :rest, :global.",
      body:
        "Lets callers pass through HTML attributes (id, class, aria-*, phx-*) without forking the component."
    },
    %{
      key: "tokens-only",
      title: "Internals compose tokens + daisyUI primitives only.",
      body:
        "No ad-hoc Tailwind utility soup. Allowed: theme tokens, intent classes, daisyUI primitive classes (btn, badge, …)."
    },
    %{
      key: "design-page",
      title: "Register every component in the host manifest.",
      body:
        "Core wrappers surface on the kit page; composites and domain components surface on the host's custom-designs page. The JSON manifest combines both. Components missing from the manifest are invisible to agents and the next contributor."
    }
  ]

  @taxonomy [
    %{
      layer: :core,
      title: "Core wrappers",
      body:
        "One wrapper per daisyUI primitive. Daisy-named (e.g. <.badge>, <.alert>, <.modal>). No domain knowledge. Lives in core_components and surfaces on the kit page."
    },
    %{
      layer: :composite,
      title: "Generic composites",
      body:
        "Multi-primitive patterns reused across domains in this app. Intent-named. Surfaces on the custom-designs page."
    },
    %{
      layer: :domain,
      title: "Domain composites",
      body:
        "Composites tied to a single product area. Intent-named, live in domain-scoped modules. Surfaces on the custom-designs page."
    }
  ]

  @doc "Returns the 5-step build-order list (data only)."
  def build_order, do: @build_order

  @doc "Returns the 5-rule wrapper contract checklist (data only)."
  def rules, do: @rules

  @doc "Returns the 3-layer module taxonomy (data only)."
  def taxonomy, do: @taxonomy
end
