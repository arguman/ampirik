ExUnit.start()

defmodule StrictArgument do
  @moduledoc """
  Strict Argument Generator.

  Supplies primitives to form an argument based on Aristotelian syllogism.

  For more information follow the link: https://en.wikipedia.org/wiki/Syllogism
  """

  defguard is_category(category)
    when category in [:major, :minor]

  defguard is_scope(scope)
    when scope in [:universal, :particular]

  defguard is_pole(pole)
    when pole in [:affirmative, :negative]

  defguard is_premise(category, term1, term2, scope, pole)
    when is_category(category)
    and is_binary(term1)
    and is_binary(term2)
    and is_scope(scope)
    and is_pole(pole)


  @todos """
  * add premise types somehow. typespecs or maybe resolve as structs?
  """

  @doc """
  Forms a premise based on major | minor category,
  for given terms and type information.

  Returns a map, consists of terms, type.

  """
  def premise(category, term1, term2, scope, pole)
    when is_premise(category, term1, term2, scope, pole)
    do
    %{__category__: category, terms: [term1, term2], type: {scope, pole}}
  end

  @doc """
  Forms a conclusion for given major and minor premises.

  Returns a map, consists of o subject, predicate and type.

  """
  def conclude(
    %{
      __category__: :major,
      terms: [middle, predicate],
      type: {:universal, :affirmative}
    },
    %{
      __category__: :minor,
      terms: [subject, middle],
      type: {:universal, :affirmative}
    }
  ) do
    %{
      terms: [subject: subject, predicate: predicate],
      type: {:universal, :affirmative}
    }
  end

  def conclude(
    %{
      __category__: :major,
      terms: [middle, predicate],
      type: {:universal, :negative}
    },
    %{
      __category__: :minor,
      terms: [subject, middle],
      type: {:universal, :affirmative}
    }
  ) do
    %{
      terms: [subject: subject, predicate: predicate],
      type: {:universal, :negative}
    }
  end

  def conclude(
    %{
      __category__: :major,
      terms: [predicate, middle],
      type: {:universal, :affirmative}
    },
    %{
      __category__: :minor,
      terms: [subject, middle],
      type: {:particular, :negative}
    }
  ) do
    %{
      terms: [
        subject: subject, predicate: predicate
      ],
      type: {:particular, :negative}
    }
  end

  def conclude(
    %{
      __category__: :major,
      terms: [middle, predicate],
      type: {:universal, :affirmative}
    },
    %{
      __category__: :minor,
      terms: [middle, subject],
      type: {:universal, :affirmative}
    }
  ) do
    %{
      terms: [
        subject: subject, predicate: predicate
      ],
      type: {:particular, :affirmative}
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
      :major, "man", "mortal", :universal, :affirmative
    )

    assert major == %{
      __category__: :major,
      terms: ["man", "mortal"],
      type: {:universal, :affirmative}
    }
  end

  test "proposes a minor premise" do
    minor = StrictArgument.premise(
      :minor, "greek", "man", :universal, :affirmative
    )

    assert minor == %{
      __category__: :minor,
      terms: ["greek", "man"],
      type: {:universal, :affirmative}
    }
  end

  test "concludes all greeks are mortal following @barbara" do
    major = StrictArgument.premise(
      :major, "man", "mortal", :universal, :affirmative
    )

    minor = StrictArgument.premise(
      :minor, "greek", "man", :universal, :affirmative
    )

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
    No birds can travel through space.
    All chickens are birds.
  ∴ No chickens can travel through space.
  """
  test "conclude no chickens can travel through space following @celarent" do
    major = StrictArgument.premise(
      :major, "bird", "travel through space", :universal, :negative
    )

    minor = StrictArgument.premise(
      :minor, "chicken", "bird", :universal, :affirmative
    )

    conclusion = StrictArgument.conclude(major, minor)

    assert conclusion == %{
      terms: [
        {:subject, "chicken"},
        {:predicate, "travel through space"}
      ],
      type: {:universal, :negative}
    }
  end

  @baroco """
    All informative things are useful.
    Some websites are not useful.
  ∴ Some websites are not informative things.
  """
  test "conclude some websites are not informative following baroco" do
    major = StrictArgument.premise(
      :major, "informative thing", "useful", :universal, :affirmative
    )

    minor = StrictArgument.premise(
      :minor, "website", "useful", :particular, :negative
    )

    conclusion = StrictArgument.conclude(major, minor)

    assert conclusion == %{
      terms: [
        {:subject, "website"},
        {:predicate, "informative thing"}
      ],
      type: {:particular, :negative}
    }
  end

  @darapti """
    All squares are rectangles.
    All squares are rhombuses.
  ∴ Some rhombuses are rectangles.
  """
  test "conclude some rhombuses are rectangles following darapti" do
    major = StrictArgument.premise(
      :major, "square", "rectangle", :universal, :affirmative
    )

    minor = StrictArgument.premise(
      :minor, "square", "rhombuse", :universal, :affirmative
    )

    conclusion = StrictArgument.conclude(major, minor)

    assert conclusion == %{
      terms: [
        {:subject, "rhombuse"},
        {:predicate, "rectangle"}
      ],
      type: {:particular, :affirmative}
    }
  end
end
