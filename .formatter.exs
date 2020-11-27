# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [
    # for maxwell
    adapter: :*,
    plug: :*
  ],
  line_length: 100
]
