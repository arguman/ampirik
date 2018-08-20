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
  def premise(:major, middle, predicate, type: {:universal, :affirmative}) do
    %{middle: middle, predicate: predicate, type: {:universal, :affirmative}}
  end

  def premise(:minor, subject, middle, type: {:universal, :affirmative}) do
    %{subject: subject, middle: middle, type: {:universal, :affirmative}}
  end

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
    {:universal, :affirmative},
    {:universal, :affirmative}
  ) do
    %{subject: subject, predicate: predicate, type: {:universal, :affirmative}}
  end

  defp do_conclude(
    subject, predicate,
    {:universal, :negative},
    {:universal, :affirmative}
  ) do
    %{subject: subject, predicate: predicate, type: {:universal, :negative}}
  end

  defp do_conclude(
    subject, predicate,
    {:universal, :affirmative},
    {:particular, :affirmative}
  ) do
    %{subject: subject, predicate: predicate, type: {:particular, :negative}}
  end

  defp do_conclude(
    subject, predicate,
    {:universal, :affirmative},
    {:universal, :affirmative}
  ) do
    %{subject: subject, predicate: predicate, type: {:particular, :affirmative}}
  end

end

defmodule StrictArgumentTest do
  use ExUnit.Case, async: true

  @barbara """
    all men are mortal.
    all greeks are men.
  ∴ all greeks are mortal.
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

  @celarent """
    no birds can travel trough space.
    all chickens are birds
  ∴ no chickens can travel through space
  """
  test "conclude chickens-dont-travel-space'ness" do

    major = %{
      middle: "bird",
      predicate: "travel trough space",
      type: {:universal, :negative}
    }

    minor = %{
      subject: "chicken",
      middle: "bird",
      type: {:universal, :affirmative}
    }

    conclusion = StrictArgument.conclude(major, minor)

    assert conclusion == %{
      subject: "chicken",
      predicate: "travel trough space",
      type: {:universal, :negative}
    }
  end

  @baroco """
    all informative things are useful
    some websites are not useful
  ∴ some websites are not informative
  """
  test "conclude some websites are not informative" do
    major = %{
      predicate: "informative",
      middle: "useful",
      type: {:universal, :affirmative},
    }

    minor = %{
      subject: "website",
      middle: "useful",
      type: {:particular, :affirmative},
    }

    conclusion = StrictArgument.conclude(major, minor)

    assert conclusion == %{
      subject: "website",
      predicate: "informative",
      type: {:particular, :negative}
    }
  end

  @darapti """
    all squares are rectangles
    all squares are rhombuses
  ∴ some rhombuses are rectangles
  """
  test "conclude some rhombuses are rectangles" do
    major = %{
      predicate: "rectangle",
      middle: "squares",
      type: {:universal, :affirmative},
    }

    minor = %{
      subject: "rhombuses",
      middle: "squares",
      type: {:universal, :affirmative},
    }

    conclusion = StrictArgument.conclude(major, minor)

    assert conclusion == %{
      subject: "rhombuses",
      predicate: "rectangle",
      type: {:particular, :affirmative}
    }
  end
end
