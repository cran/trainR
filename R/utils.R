#' Wrapper for \code{\link[base:getElement]{base::getElement}}
#'
#' Wrapper for \code{\link[base:getElement]{base::getElement}}, but instead of
#' returning \code{NULL} when the \code{name} is not found, returns an user
#' specified \code{default} value, \code{NA}.
#'
#' @inheritParams base::getElement
#' @param as_list Boolean flag to return the element as a list.
#' @param default Default value to return if \code{name} is not found.
#'
#' @return Element from object, if exists, \code{default} otherwise.
#' @keywords internal
#' @noRd
#' @examples
#' test_obj <- list(a = 4, c = 2)
#' trainR:::get_element(test_obj, "a")
#' trainR:::get_element(test_obj, "b")
get_element <- function(object, name, as_list = FALSE, default = NA) {
  tryCatch({
  out <- getElement(object, name)
  if (is.null(out))
    return(default)
  if (as_list)
    return(out)
  unlist(out)
  }, error = function(e) {
    if (as_list)
      return(default)
    return(default)
  })
}

#' Get the full station name
#' @param crs (string, 3 characters, alphabetic): The CRS code of the station.
#' @return String with station name.
#' @keywords internal
get_location <- function(crs) {
  # Local binding
  station_codes <- trainR::station_codes
  if (all(crs %in% station_codes$crs))
    return(purrr::map_chr(crs, ~station_codes$name[station_codes$crs == .]))
  return("UNK")
}

#' Get user's token
#'
#' Get user's token to access the National Rail Enquiries (NRE) data feeds.
#'
#' @param ENV String with environment variable containing the token to access
#'     the NRE data feeds (default = "NRE").
#'
#' @return String with token.
#' @export
get_token <- function(ENV = "NRE") {
  token <- Sys.getenv(ENV)
  if (token == "")
    stop("The access token to the NRE was not found, `NRE`. ",
         "Make sure to run `trainR::set_token()` to configure it.",
         call. = FALSE)
  token
}

#' Validate station code (CRS)
#'
#' @param x Station code.
#' @param parameter String with the name of the parameter to check.
#'
#' @return Nothing, call for its side effect.
#' @keywords internal
is_valid_crs <- function(x, parameter = "crs") {
  # Local binding
  station_codes <- trainR::station_codes
  if (!(x %in% station_codes$crs))
    stop(glue::glue("The given value for `{parameter}`, {x}, it is not a ",
                    "valid CRS code. Check trainR::station_codes$crs for ",
                    "valid codes."),
         call. = FALSE)
}

#' Update class of data object
#'
#' @param data Data object (e.g. \code{list}).
#' @param class String of new class.
#'
#' @return Original data object with new \code{class}.
#' @keywords internal
#' @noRd
#' @examples
#' out <- list(woof = list(name = "Barto", age = 6)) %>%
#'   trainR:::reclass(names(.))
reclass <- function(data, class) {
  if (!is.null(class) & !inherits(data, class))
    class(data) <- c(class, class(data))
  data
}

#' Configure user's token
#'
#' Configure user's token to access the National Rail Enquiries (NRE) data
#' feeds.
#'
#' To obtain an access token, you must complete the registration form found at
#' \url{http://realtime.nationalrail.co.uk/OpenLDBWSRegistration/}.
#'
#' @return Nothing, helper function to set up environment variable.
#' @export
set_token <- function() {
  usethis::edit_r_environ(scope = "user")
}

#' Validate output from \code{request}
#'
#' @param data Data object (e.g. \code{list}).
#'
#' @return Original data object, if data is valid
#' @keywords internal
validate <- function(data) {
  if ("Reason" %in% names(data))
    stop(glue::glue("[{get_element(data, 'Code')}] ",
                    "{get_element(data, 'Reason')}"),
         call. = FALSE)
  data
}
