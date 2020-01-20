#!/usr/bin/env Rscript

library(dplyr)
library(googlesheets4)
library(readr)
library(purrr)
library(stringr)
library(tidyr)
library(yaml)

# input spreadsheet
SHEET_ID <- "1q3lo8kQEsPcPWbOb-Y6t097WA5doMpfX-v3EbWHCKdA"

# where the images should go
DATA_FILE <- file.path(system2("git", c("rev-parse", "--show-toplevel"), stdout=TRUE), "_data/2020/data.yml")

make_speaker_id <- function(name) {
    name %>%
        trimws(which="both") %>%
        iconv(to="ASCII//TRANSLIT") %>%
        str_replace_all("\\s+", "_") %>%
        str_to_lower()
}

make_session_id <- function(title) {
    title %>%
        trimws(which="both") %>%
        str_replace_all("[:?,_+'’&—().!]", "") %>%
        str_replace_all("\\s+", "-") %>%
        str_replace_all("[-]+", "-") %>%
        str_to_lower()
}

is_empty_string <- function(x) typeof(x) == "character" && nchar(x) == 0

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

create_speaker <- function(x) {
    list(
      id=x$speaker_id,
      name=x$name,
      affiliation=x$affiliation,
      url=x$url,
      bio=x$bio,
      twitter=x$twitter,
      website=x$website
    ) %>%
    discard(is_empty_string)
}

create_talk <- function(x) {
    f <- x[[1]]
    list(
      id=f$talk_id,
      title=f$title,
      type=f$type,
      time=f$time,
      date=f$date,
      room=f$room,
      hashtags=create_hashtags(f$hashtags),
      video=f$video,
      abstract=f$abstract,
      excerpt=f$excerpt,
      speakers=map(x, create_speaker)
    ) %>%
    discard(is_empty_string)
}

talks_raw <- sheets_read(SHEET_ID, trim_ws=T, na="")

talks_df <-
    talks_raw %>%
    # from some reason the na argument at sheets_read does not work
    mutate_all(replace_na, replace="") %>%
    mutate(
        accepted=if_else(accepted == "Yes", TRUE, FALSE),
        active=if_else(active == "", TRUE, isTRUE(active)),
        session_id=map_chr(title, make_session_id),
        speaker_id=map_chr(name, make_speaker_id),
        talk_id=as.integer(talk_id),
        twitter=ifelse(is.na(twitter), "", str_replace(twitter, "^@", ""))
    ) %>%
    filter(accepted) %>%
    arrange(type, session_id)

# convert the data frame into a list where each element is a nested list with
# speakers
talk_list <-
  split(talks_df, talks_df$talk_id) %>%
  map(transpose) %>%
# the talk_id becomes the name of the list element
# which we do not want
  strip_names() %>%
  map(create_talk)

list(talks=talk_list) %>%
  as.yaml() %>%
  ## cat()
  cat(file=DATA_FILE)
