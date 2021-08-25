#!/usr/bin/env Rscript

library(dplyr)
library(googlesheets4)
library(readr)
library(purrr)
library(stringr)
library(tidyr)
library(yaml)

# input spreadsheet
SHEET_ID <- "1xfJcyL8KEf0nQeLd-yJ5-QJ80VkL1d9o-KLlul6kiTw"

# where the images should go
DATA_FILE <- file.path(system2("git", c("rev-parse", "--show-toplevel"), stdout=TRUE), "_data/2021-ECOOP/data.yml")

make_speaker_id <- Vectorize(function(name) {
    name %>%
        trimws(which="both") %>%
        iconv(to="ASCII//TRANSLIT") %>%
        str_replace_all("\\s+", "_") %>%
        str_to_lower()
}, USE.NAMES = FALSE)

make_session_id <- function(title) {
    title %>%
        trimws(which="both") %>%
        str_replace_all("[:?,_+'’&—().!]", "") %>%
        str_replace_all("\\s+", "-") %>%
        str_replace_all("[-]+", "-") %>%
        str_to_lower()
}

is_empty_string <- function(x) {
  is.na(x) || is.null(x) || (typeof(x) == "character" && nchar(x) == 0)
}

strip_names <- function(x) {
  names(x) <- NULL
  x
}

create_hashtags <- function(x) {
  if (!is_empty_string(x)) {
    trimws(unlist(str_split(x, ",")), which="both")
  } else {
    ""
  }
}

create_person <- function(x, type) {
  if (is_empty_string(x[[type]])) {
    NULL
  } else {
    list(
      name=x[[type]],
      id=make_speaker_id(x[[type]]),
      type=str_replace(type, "(.*)_.*", "\\1"),
      affiliation=x[[str_c(type, "_affiliation")]],
      twitter=x[[str_c(type, "_twitter")]],
      website=x[[str_c(type, "_website")]],
      bio=if (type=="speaker") x$bio
    ) %>%
    discard(is_empty_string)
  }
}

create_talk <- function(x) {
    list(
      id=x$talk_id,
      title=x$title,
      time=x$time,
      hashtags=create_hashtags(x$hashtags),
      video_id=x$video_id,
      abstract=x$abstract,
      persons=map(c("speaker", "panelist_1", "panelist_2"), ~create_person(x, .)) %>% discard(is.null)
    ) %>%
    discard(is_empty_string)
}

talks_raw <- sheets_read(SHEET_ID, sheet="Speakers", trim_ws=T)

options(dplyr.width = Inf)

talks_df <-
    talks_raw %>%
    mutate_all(replace_na, replace="") %>%
    mutate(
        id=as.integer(id)
    ) %>%
    arrange(id)

# convert the data frame into a list where each element is a nested list with
# speakers
talk_list <-
  talks_df %>%
  transpose %>%
  map(create_talk)

list(talks=talk_list) %>%
  as.yaml() %>%
  cat(file=DATA_FILE)
