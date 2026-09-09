doc = LazyHTML.from_fragment(~s(<ul id="signups"><li class="x">ada</li></ul>))
IO.inspect(LazyHTML.filter(doc, "li"))
IO.inspect(Enum.to_list(doc))
