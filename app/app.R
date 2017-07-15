library(reticulate, lib.loc = "/usr/local/lib/R/site-library")
library(DBI, lib.loc = "/usr/local/lib/R/site-library")
library(rmarkdown, lib.loc = "/usr/local/lib/R/site-library")

flask = import('flask')
app = flask$Flask('__main__')

index = function() {
  render("/app/static/index.Rmd")
  return("/app/static/index.html")
  }
app$add_url_rule('/', 
                 methods=list("GET","POST"),
                 view_func = index)

app$run(host="0.0.0.0",port=3000)
