{
  "cool.io" = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "03wwgs427nmic6aa365d7kyfbljpb1ra6syywffxfmz9382xswcp";
      type = "gem";
    };
    version = "1.5.3";
  };
  fluentd = {
    dependencies = ["cool.io" "http_parser.rb" "msgpack" "ruby_dig" "serverengine" "sigdump" "strptime" "tzinfo" "tzinfo-data" "yajl-ruby"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wkab48zahbdhnp6gwagszhyx15yabnvv1b9kzv7h2v7bdxmfmh7";
      type = "gem";
    };
    version = "0.14.25";
  };
  fluentd_regexp_tester = {
    dependencies = ["fluentd" "thor"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pxhzw4ybrib07ms3kiay37v8b4a4ivy2zcpgax4xi42wp2igcag";
      type = "gem";
    };
    version = "0.1.4";
  };
  "http_parser.rb" = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15nidriy0v5yqfjsgsra51wmknxci2n2grliz78sf9pga3n0l7gi";
      type = "gem";
    };
    version = "0.6.0";
  };
  msgpack = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09xy1wc4wfbd1jdrzgxwmqjzfdfxbz0cqdszq2gv6rmc3gv1c864";
      type = "gem";
    };
    version = "1.2.4";
  };
  ruby_dig = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1qcpmf5dsmzxda21wi4hv7rcjjq4x1vsmjj20zpbj5qg2k26hmp9";
      type = "gem";
    };
    version = "0.0.2";
  };
  serverengine = {
    dependencies = ["sigdump"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1gkm880njsi9x6vpb5grsspxb097hi8898drlbbkj1wl9qf2xv8l";
      type = "gem";
    };
    version = "2.0.7";
  };
  sigdump = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1mqf06iw7rymv54y7rgbmfi6ppddgjjmxzi3hrw658n1amp1gwhb";
      type = "gem";
    };
    version = "0.2.4";
  };
  strptime = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1avbl1fj4y5qx9ywkxpcjjxxpjj6h7r1dqlnddhk5wqg6ypq8lsb";
      type = "gem";
    };
    version = "0.1.9";
  };
  thor = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nmqpyj642sk4g16nkbq6pj856adpv91lp4krwhqkh2iw63aszdl";
      type = "gem";
    };
    version = "0.20.0";
  };
  thread_safe = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nmhcgq6cgz44srylra07bmaw99f5271l0dpsvl5f75m44l0gmwy";
      type = "gem";
    };
    version = "0.3.6";
  };
  tzinfo = {
    dependencies = ["thread_safe"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fjx9j327xpkkdlxwmkl3a8wqj7i4l4jwlrv3z13mg95z9wl253z";
      type = "gem";
    };
    version = "1.2.5";
  };
  tzinfo-data = {
    dependencies = ["tzinfo"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fkihwl9k9pmygl6c4kdlzqv51hn33bvjnxs4q48gs4s63d8gva2";
      type = "gem";
    };
    version = "1.2018.5";
  };
  yajl-ruby = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16v0w5749qjp13xhjgr2gcsvjv6mf35br7iqwycix1n2h7kfcckf";
      type = "gem";
    };
    version = "1.4.1";
  };
}