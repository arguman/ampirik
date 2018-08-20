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
  @types [
    {:universal, :affirmative},
    {:universal, :negative},
    {:particular, :affirmative},
    {:particular, :negative}
  ]

  @major_terms [:predicate, :middle]
  @minor_terms [:subject, :middle]

  defguard is_type(type) when type in @types
  defguard is_major_term(term) when term in @major_terms
  defguard is_minor_term(term) when term in @minor_terms


  @doc """
  Forms a premise based on major | minor category,
  for given terms and type information.

  Returns a map, consists of terms, type.

  """
  def premise(:major, [{term1, _}, {term2, _}] = terms, type)
  when is_major_term(term1) and is_major_term(term2) and is_type(type)
  do
    %{terms: terms, type: type}
  end

  def premise(:minor, [{term1, _}, {term2, _}] = terms, type)
  when is_minor_term(term1) and is_minor_term(term2) and is_type(type)
  do
    %{terms: terms, type: type}
  end

  @doc """
  Forms a conclusion for given major and minor premises.

  Returns a map, consists of o subject, predicate and type.

  """
  def conclude(
    %{
      terms: [
        {:middle, middle},
        {:predicate, predicate}
      ],
      type: {:universal, :affirmative}
    },
    %{
      terms: [
        {:middle, middle},
        {:subject, subject}
      ],
      type: {:universal, :affirmative}
    }
  ) do
    %{
      terms: [
        {:subject, subject},
        {:predicate, predicate}
      ],
      type: {:particular, :affirmative}
    }
  end

  def conclude(
    %{
      terms: [
        {:predicate, predicate},
        {:middle, middle}
      ],
      type: {:universal, :affirmative}
    },
    %{
      terms: [
        {:subject, subject},
        {:middle, middle},
      ],
      type: {:particular, :affirmative}
    }
  ) do
    %{
      terms: [
        {:subject, subject},
        {:predicate, predicate}
      ],
      type: {:particular, :negative}
    }
  end

  def conclude(
    %{
      terms: [
        {:middle, middle},
        {:predicate, predicate}
      ],
      type: {:universal, :negative}
    },
    %{
      terms: [
        {:subject, subject},
        {:middle, middle},
      ],
      type: {:universal, :affirmative}
    }
  ) do
    %{
      terms: [
        {:subject, subject},
        {:predicate, predicate}
      ],
      type: {:universal, :negative}
    }
  end

  def conclude(
    %{
      terms: [
        {:middle, middle},
        {:predicate, predicate}
      ],
      type: {:universal, :affirmative}
    },
    %{
      terms: [
        {:subject, subject},
        {:middle, middle}
      ],
      type: {:universal, :affirmative}
    }
  ) do
    %{
      terms: [
        subject: subject,
        predicate: predicate
      ],
      type: {:universal, :affirmative}
    }
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
    major = StrictArgument.premise(
      :major,
      [middle: "man", predicate: "mortal"],
      {:universal, :affirmative}
    )

    assert major == %{
      terms: [middle: "man", predicate: "mortal"],
      type: {:universal, :affirmative}
    }
  end

  test "proposes a minor premise" do
    minor = StrictArgument.premise(
      :minor,
      [subject: "greek", middle: "man"],
      {:universal, :affirmative}
    )

    assert minor == %{
      terms: [
        subject: "greek",
        middle: "man"
      ],
      type: {:universal, :affirmative}
    }
  end

  test "concludes all greeks are mortal" do
    major = %{
      terms: [
        middle: "man",
        predicate: "mortal"
      ],
      type: {:universal, :affirmative}
    }

    minor = %{
      terms: [
        subject: "greek",
        middle: "man"
      ],
      type: {:universal, :affirmative}
    }

    conclusion = StrictArgument.conclude(major, minor)

    assert conclusion == %{
      terms: [
        subject: "greek",
        predicate: "mortal"
      ],
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
      terms: [
        middle: "bird",
        predicate: "travel trough space"
      ],
      type: {:universal, :negative}
    }

    minor = %{
      terms: [
        subject: "chicken",
        middle: "bird"
      ],
      type: {:universal, :affirmative}
    }

    conclusion = StrictArgument.conclude(major, minor)

    assert conclusion == %{
      terms: [
        {:subject, "chicken"},
        {:predicate, "travel trough space"}
      ],
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
      terms: [
        {:predicate, "informative"},
        {:middle, "useful"}
      ],
      type: {:universal, :affirmative},
    }

    minor = %{
      terms: [
        {:subject, "website"},
        {:middle, "useful"}
      ],
      type: {:particular, :affirmative},
    }

    conclusion = StrictArgument.conclude(major, minor)

    assert conclusion == %{
      terms: [
        {:subject, "website"},
        {:predicate, "informative"}
      ],
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
      terms: [
        {:middle, "square"},
        {:predicate, "rectangle"}
      ],
      type: {:universal, :affirmative},
    }

    minor = %{
      terms: [
        {:middle, "square"},
        {:subject, "rhombuses"}
      ],
      type: {:universal, :affirmative},
    }

    conclusion = StrictArgument.conclude(major, minor)

    assert conclusion == %{
      terms: [
        {:subject, "rhombuses"},
        {:predicate, "rectangle"}
      ],
      type: {:particular, :affirmative}
    }
  end
end
