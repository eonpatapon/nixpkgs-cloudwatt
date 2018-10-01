{ stdenv, pkgs, bundlerEnv, ruby, curl }:

bundlerEnv {
  inherit ruby;

  pname = "fluentd_regexp_tester";
  gemdir = ./.;

  meta = with pkgs.lib; {
    description = "Simple cli tool to test regexp with the fluent parser";
    homepage    = https://github.com/eonpatapon/fluentd_regexp_tester;
    license     = licenses.mit;
    maintainers = with maintainers; [ jpbraun ];
    platforms   = platforms.unix;
  };
}
