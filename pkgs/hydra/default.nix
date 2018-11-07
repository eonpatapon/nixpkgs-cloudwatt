{ hydra, fetchFromGitHub }:

hydra.overrideAttrs(old: {
    name = "hydra-unstable-2018-10-17";
    # Support 9.3 Postgresql
    # Add GitlabPR plugin
    # Add evaluation status
    src = fetchFromGitHub {
      owner = "nlewo";
      repo = "hydra";
      rev = "40f1e1e858c03dd5625170674b13312552e8b54f";
      sha256 = "09n76rbp4s64d1xcnwl6yzz0ga1qwjf8f7l4lfq972w96rh1gyp8";
    };
})
