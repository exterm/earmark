defmodule Regressions.I119FootnotesInsideLiTest do
  use ExUnit.Case
  
  @footnote """
  foo[^1] again
  
  [^1]: bar baz
  """
  test "footnotes still work" do
    assert with_fn(@footnote) == {~s{<p>foo<a href="#fn:1" id="fnref:1" class="footnote" title="see footnote">1</a> again</p>\n<div class="footnotes">\n<hr>\n<ol>\n<li id="fn:1"><p>bar baz&nbsp;<a href="#fnref:1" title="return to article" class="reversefootnote">&#x21A9;</a></p>\n</li>\n</ol>\n\n</div>}, []}
  end

  @li_footnote """
  1. foo[^1]
  
  [^1]: bar baz
  """
  test "footnotes in list items do not crash (no footnotes)" do
    assert without_fn(@li_footnote) == {~s{<ol>\n<li>foo[^1]\n</li>\n</ol>\n<p>[^1]: bar baz</p>\n}, []}
  end

  test "footnotes in list items do not crash (footnotes)" do
    assert with_fn(@li_footnote) == {
      ~s{<ol>\n<li>foo<a href="#fn:1" id="fnref:1" class="footnote" title="see footnote">1</a>\n</li>\n</ol>\n<div class=\"footnotes\">\n<hr>\n<ol>\n<li id=\"fn:1\"><p>bar baz&nbsp;<a href=\"#fnref:1\" title=\"return to article\" class=\"reversefootnote\">&#x21A9;</a></p>\n</li>\n</ol>\n\n</div>},
      []}
  end

  @undefined """
  foo[^1]
  hello

  [^2]: bar baz
  """
  test "undefined footnotes do not crash" do
    assert with_fn(@undefined) == {~s{<p>foo[^1]\nhello</p>\n}, [{:error, 1, "footnote 1 undefined, reference to it ignored"}]}
  end

  @nofns """
  foo[^1]
  hello
  """
  test "undefined footnotes (none at all) do not crash" do
    assert with_fn(@nofns) == {~s{<p>foo[^1]\nhello</p>\n}, [{:error, 1, "footnote 1 undefined, reference to it ignored"}]}
  end


  @illdefined """
  foo[^1] again

  [^1]:bar baz
  """
  test "illdefined footnotes no not crash" do
    assert with_fn(@illdefined) == {~s{<p>foo[^1] again</p>\n<p>[^1]:bar baz</p>\n},
     [{:error, 3, "footnote 1 undefined, reference to it ignored"},
      {:error, 1, "footnote 1 undefined, reference to it ignored"}]}
  end
  defp with_fn(md), do: Earmark.as_html(md, %Earmark.Options{footnotes: true})
  defp without_fn(md), do: Earmark.as_html(md, %Earmark.Options{footnotes: false})
end