## Simple Uptime Monitor

Built with [Ruby](https://www.ruby-lang.org/en/), [Sinatra](http://www.sinatrarb.com/), [Faye](http://faye.jcoglan.com/ruby.html), [Redis](http://redis.io/), and [D3.JS](https://d3js.org/)

Faye runs as Rack middleware, Sinatra handles initial HTTP request/serving of client assets (which uses D3.JS for visualization). Redis holds on to the monitoring data in a TRIM'd List.

Mostly just a quick experiment to get more familiar with the technologies listed above.

```
bundle install
foreman start
```

Then open browser to `http://localhost:9292/`

