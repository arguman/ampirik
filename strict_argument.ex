ExUnit.start()

defmodule StrictArgument do
  @moduledoc """
  Strict Argument Generator.

  Supplies primitives to form an argument based on Aristotelian syllogism.

  For more information follow the link: https://en.wikipedia.org/wiki/Syllogism
  """

  @doc """
  Forms a premise for given category, and related arguments.

  ### Arguments

  * category: can be either `:major` or `:minor`.
    `:major` dictates a middle, and predicate in order.
    `:minor` dictates a subject and middle in order.
  * arg1: can behave as either `middle` or `subject` based on given category.
  * arg2: can behave as either `predicate` or `middle` based on given category.
  * type: 2 symbol based tuple defining characteristics of the premise.
    `{:universal, :affirmative}`

  ### Returns

  A major or minor premise given related subject, middle or predicate,
  includes type as 2 arg tuple.

  """
  def premise(:major, middle, predicate, type: {:universal, :affirmative}),
    do: %{middle: middle, predicate: predicate, type: {:universal, :affirmative}}

  def premise(:minor, subject, middle, type: {:universal, :affirmative}),
    do: %{subject: subject, middle: middle, type: {:universal, :affirmative}}

  @doc """
  Forms a conclusion for given major and minor premises.

  ### Arguments

  * major: major premise that consists of a middle and a predicate term.
    `%{middle: "", predicate: "", type: {:universal, :affirmative}}`
  * minor: minor premise that consists of a subject and a middle term.
    `%{subject: "", middle: "", type: {:universal, :affirmative}}`

  ### Returns

  A conclusion consists o subject, predicate and type.

  """
  def conclude(
    %{predicate: predicate, middle: middle, type: major_type},
    %{subject: subject, middle: middle, type: minor_type}
  ) do
    do_conclude(subject, predicate, major_type, minor_type)
  end

  defp do_conclude(
    subject, predicate,
    {:universal, :affirmative}, {:universal, :affirmative}
  ), do: %{subject: subject, predicate: predicate, type: {:universal, :affirmative}}
end

defmodule StrictArgumentTest do
  use ExUnit.Case, async: true

  @barbara """
  All men are mortal.
  All greeks are men.
  All greeks are mortal.
  """

  test "proposes a major premise" do
    major = StrictArgument.premise(:major, "man", "mortal", type: {:universal, :affirmative})

    assert major == %{
      middle: "man",
      predicate: "mortal",
      type: {:universal, :affirmative}
    }
  end

  test "proposes a minor premise" do
    minor = StrictArgument.premise(:minor, "greek", "man", type: {:universal, :affirmative})

    assert minor == %{
      subject: "greek",
      middle: "man",
      type: {:universal, :affirmative}
    }
  end

  test "concludes universal affirmative" do
    major = %{
      middle: "man",
      predicate: "mortal",
      type: {:universal, :affirmative}
    }

    minor = %{
      subject: "greek",
      middle: "man",
      type: {:universal, :affirmative}
    }

    conclusion = StrictArgument.conclude(major, minor)

    assert conclusion == %{
      subject: "greek",
      predicate: "mortal",
      type: {:universal, :affirmative}
    }
  end
end
