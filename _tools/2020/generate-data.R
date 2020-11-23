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
    y <- x[[1]]
    list(
      id=y$talk_id,
      title=y$title,
      type=y$type,
      time1=y$first,
      time2=y$second,
      hashtags=create_hashtags(y$hashtags),
      video_id=y$video_id,
      abstract=y$abstract,
      excerpt=y$excerpt,
      speakers=map(x, create_speaker)
    ) %>%
    discard(is_empty_string)
}

args <- commandArgs(trailingOnly=TRUE)
video_file <- NULL
if (length(args) == 1) {
  video_file <- args[1]
}

talks_raw <- sheets_read(SHEET_ID, sheet="Speakers", trim_ws=T, na="???")
schedule_raw <- sheets_read(SHEET_ID, sheet="Schedule", trim_ws=T, na="???")

options(dplyr.width = Inf)

talks_df <-
    talks_raw %>%
    mutate_all(replace_na, replace="") %>%
    mutate(
        show=if_else(show == "yes", TRUE, FALSE),
        session_id=map_chr(title, make_session_id),
        speaker_id=map_chr(name, make_speaker_id),
        talk_id=as.integer(talk_id),
        twitter=ifelse(is.na(twitter), "", str_replace(twitter, "^@", "")),
        type="talk"
    ) %>%
    filter(show) %>%
    arrange(type, session_id)

schedule_df <-
  schedule_raw %>%
    # from some reason the na argument at sheets_read does not work
    mutate_all(replace_na, replace="") %>%
    transmute(
      name=Name,
      first=`First talk`,
      second=`Second talk`
    )

video_df <- if (!is.null(video_file)) {
  library(jsonlite)
  tmp <- fromJSON(video_file)$item$snippet
  tibble(
    title=tmp$title,
    video_id=tmp$resourceId$videoId
  )
} else {
  tibble(title=NA, video_id=NA)
}

talks_df <-
  talks_df %>%
  left_join(schedule_df, by="name") %>%
  left_join(video_df, by="title") %>%
  mutate(video_id=ifelse(is.na(video_id.x) | video_id.x == "", video_id.y, video_id.x)) %>%
  select(-video_id.x, -video_id.y)

missing <- filter(talks_df, is.na(first))
if (nrow(missing) != 0) {
  message("Missing schedule for:")
  cat(missing$name, sep="\n")
  q(status=1, save=FALSE)
}

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
