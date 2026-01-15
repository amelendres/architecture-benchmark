local json = require "cjson"
json.decode_array_with_array_mt(true)

done = function(summary, latency, requests)
  sec = summary.duration/1000000
  -- io.write("------------------------------\n")
  -- io.write(json.encode(summary))
  -- io.write(json.encode(latency.percentile))
  -- io.write("------------------------------\n")



  file = io.open("results/http.json", "w")
  file:write(string.format([[
    {
      "p50": %.2f,
      "p95": %.2f,
      "p99": %.2f,
      "avg": %.2f,
      "rps": %.2f
    }
    ]],
    latency:percentile(50) / 1e3,
    latency:percentile(95) / 1e3,
    latency:percentile(99) / 1e3,
    latency.mean / 1e3,
    summary.requests / sec
  ))
  file:close()


  summary_json = io.open("results/http_summary.json", "w")
  summary_json:write(json.encode(summary))
  summary_json:close()

  -- latency_json = io.open("results/http_latency.json", "w")
  -- latency_json:write(json.encode(latency.percentile))
  -- latency_json:close()

end