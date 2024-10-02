# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [
    resource: 2,
    resource: 3
  ],
  export: [
    locals_without_parens: [
      resource: 2,
      resource: 3
    ]
  ]
]
