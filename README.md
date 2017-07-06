# The `midas` Touch
Nicholas Jhirad  

[![CRAN Status Badge](https://www.r-pkg.org/badges/version/midas)](https://cran.r-project.org/package=midas) [![CRAN Total Downloads](http://cranlogs.r-pkg.org/badges/grand-total/midas)](https://cran.r-project.org/package=midas) [![CRAN Monthly Downloads](http://cranlogs.r-pkg.org/badges/midas)](https://cran.r-project.org/package=midas)



## The midas package

This document covers version >= 0.2.0 of the package and is intended to be an  
introduction to the package, 

The `midas` package turns html code that you can find
around the internet into the necessary shiny functions that 
would generate the equivalent shiny objects

## Package Details

The package depends on:
 
 * `xml2` parses html
 * `shiny` supports the shiny-object class and the `tag` function

## Why Convert HTML?

Shiny is best when it lets us take what we see elsewhere and reproduce it in a fraction of the time attached to some great data-analysis.

I found myself with the following workflow:


```r
# Copy an existing widget or html object
# Either from the web or from an existing function
library(shiny)
library(shinydashboard)

cat(as.character(dashboardHeader()), fill = TRUE)
```

```
## <header class="main-header">
##   <span class="logo"></span>
##   <nav class="navbar navbar-static-top" role="navigation">
##     <span style="display:none;">
##       <i class="fa fa-bars"></i>
##     </span>
##     <a href="#" class="sidebar-toggle" data-toggle="offcanvas" role="button">
##       <span class="sr-only">Toggle navigation</span>
##     </a>
##     <div class="navbar-custom-menu">
##       <ul class="nav navbar-nav"></ul>
##     </div>
##   </nav>
## </header>
```

```r
# Reproduce and Modify
logoHeader <- function(href = '#',
                       logosrc = 'logo.png',
                       loadersrc = 'loader.gif',
                       height='78%',
                       width='78%',
                       navbar = NULL) {
    tagList(
        tags$head(
            tags$script(
                "setInterval(function(){
            if ($('html').attr('class')=='shiny-busy') {
              $('div.busy').show();
              $('div.notbusy').hide();
            } else {
          $('div.busy').hide();
          $('div.notbusy').show();
        }
      },100)")
        ),
      tags$header(
          class = 'main-header',
          tags$span(
              class = 'logo',
              tags$a(href='#', class = 'logo',
                     tags$div(
                         class = 'busy',
                         tags$img(src = loadersrc,
                                  height = height,
                                  width = width)
                     ),
                     tags$div(
                         class = 'notbusy',
                         tags$img(src = logosrc,
                                  height = height,
                                  width = width)
                     )
              )
          ),
          navbar
          
      )
    )
}
```

But for giant pages, this involved a considerable amount of transcription of things like: `<div class="example"></div>` into `tags$div(class="example")`.

I felt that this should be programmatic.

## Converting HTML with midas

Let's try this with midas!

Here's some HTML I found on the internet:


```r
# Let's Try this with midas!
library(midas)

html <- 
'<html>
<head>
<style>
#p01 {
    color: blue;
}
</style>
</head>
<body>

<p>This is a paragraph.</p>
<p>This is a paragraph.</p>
<p id="p01">I am different.</p>

</body>
</html>'

print(turn_shiny(html))
```

```
## tag("html", list(tag("head", list(tag("style", list("#p01 {    color: blue;}")))), tag("body", list(tag("p", list("This is a paragraph.")), tag("p", list("This is a paragraph.")), tag("p", list(id = "p01", "I am different."))))))
## [1] "tag(\"html\", list(tag(\"head\", list(tag(\"style\", list(\"#p01 {    color: blue;}\")))), tag(\"body\", list(tag(\"p\", list(\"This is a paragraph.\")), tag(\"p\", list(\"This is a paragraph.\")), tag(\"p\", list(id = \"p01\", \"I am different.\"))))))"
```
