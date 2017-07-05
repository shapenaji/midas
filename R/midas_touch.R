#' Uses xml2 to parse html text into a list
#'
#' @param x string of html
#'
#' @return html as an R list
#' @export
#'
#' @importFrom xml2 read_html as_list
#' @examples
#' # create some test data
#' html <- '<div class="example"><h3>test</h3></div>'
#' html_to_list(html)
html_to_list <- function(x) {
    xdoc <- xml2::read_html(x)
    page <- xml2::as_list(xdoc)
    if(length(page) > 1)
        page <- list(html = page)
    page
}

#' turns an xml2 list into a shiny function call
#'
#' @param root an html list (from xml2 as_list).
#'    Note: If the list is particularly deep,
#'    you may need to set option(expressions = SOMETHING BIG)
#' @return a function call that produces the equivalent shiny objects. 
#'    This will include comments, so we recommend pre-processing to remove lines which contain html comments.
#' @export
#' @importFrom shiny tag
#' @examples
#' html <- '<div class="example"><h3>test</h3></div>'
#' html_list <- html_to_list(html)
#' gold <- midas_touch(html_list)
#' library(shiny)
#' eval(gold)
midas_touch <- function(root) {
    xattrs <- attributes(root[[names(root)]])

    xnames <- xattrs$names
    xclass <- xattrs$.class
    xother <- xattrs[setdiff(names(xattrs), c('names','.class'))]
    xother[['class']] = xclass
    baseroot <- root[[names(root)]]
    attributes(baseroot) <- NULL

    if (length(baseroot) > 0)
        baseroot <- baseroot[sapply(baseroot, function(x) !is.list(x))]

    call('tag',
         names(root),
         c(xother,
           unname({
               lapply(
                   which(nzchar(as.vector(xnames))),
                   function(index) midas_touch(root[[1]][index])
               )
           }),
           baseroot
         )
    )
}

#' Turns a string of html into the equivalent shiny code
#'
#' @param html a string of complete html
#' @param remove_newlines whether or not to remove newlines from the string
#' @param file default (NULL) is to return the object, if this is set it will write to file
#'
#' @return a function call that produces the equivalent shiny objects
#' @export
#'
#' @examples
#' 
#' # A simple example, if xml2 can parse it
#' # midas can touch it.
#' html <- '<div class="example"><h3>test</h3></div>'
#' turn_shiny(html)
#' 
#' # Load shiny so we can evaluate shiny code
#' library(shiny)
#' eval(parse(text = turn_shiny(html)))
turn_shiny <-
    function(
        html,
        remove_newlines = TRUE,
        file = NULL
    ) {
    if (remove_newlines)
        html <- gsub('\n', '', html)
    x <- html_to_list(html)
    out <-
        as.character(
            as.expression(
                midas_touch(x)
            )
        )
    cat(out, fill = TRUE)
    if (is.null(file)) {
        return(invisible(out))
    } else {
        cat(out, fill = TRUE, file = file)
    }
}





