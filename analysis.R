version <- "1.0"



# Packages --------------------------------------------------------
library(here)
library(janitor)
library(tidyverse)




# functions -------------------------------------------------------
write_obj <- function(obj, name, ver = NULL, dir = "") {
  if (!is.null(ver)) {
    out_path <- here::here(glue::glue("{dir}/{name}_{ver}.rds"))
    readr::write_rds(obj, out_path)
  }
  readr::write_rds(obj, here::here(dir, glue::glue("{name}.rds")))
}

write_output <- function(obj, name, ver = NULL) {
  write_obj(obj, name, ver, "output")
  obj
}

write_data <- function(obj, name, ver = NULL) {
  write_obj(obj, name, ver, "data")
  obj
}

write_plot <- function(gg = last_plot(), name, ver = NULL) {
  custom_save <- function(name, gg) {
    ggplot2::ggsave(
      name, gg,
      path = here::here("output"),
      width = 16, height = 9, units = "cm", dpi = "retina", scale = 2
    )
  }

  if (!is.null(ver)) {
    custom_save(glue::glue("{name}_{ver}.png"), gg)
  }

  custom_save(glue::glue("{name}.png"), gg)

  invisible(gg)
}

preproc <- function(db_raw) {
  db_raw |>
    janitor::clean_names() |>
    dplyr::select(species, sex, body_mass_g, culmen_depth_mm)
}




# tests -----------------------------------------------------------
withr::with_package("testthat", {
  with_reporter(default_reporter(), {


    test_that("preproc() returns expected number of cols", {
      # setup
      db_raw <- readr::read_csv(here::here("data-raw/penguins.csv"))

      # eval
      db <- preproc(db_raw)

      # test
      ncol(db) |> expect_equal(4)
    })

  })
})




# read and preproc ------------------------------------------------
db_raw <- read_csv(here("data-raw/penguins.csv"))
penguins <- db_raw |>
  preproc() |>
  write_data("penguins", ver = version)




# Analysis --------------------------------------------------------
gg <- penguins |>
  ggplot(aes(culmen_depth_mm, body_mass_g)) +
  geom_smooth(method = lm, colour = "black", linetype = "dashed") +
  geom_smooth(aes(colour = species), method = lm) +
  geom_point(aes(shape = sex, colour = species)) +
  theme(legend.position = "top")

write_plot(gg, "gg", ver = version)


mod_depth <- lm(body_mass_g ~ culmen_depth_mm, data = penguins) |>
  write_output("mod_depth", ver = version)

mod_depth_spec <- lm(
  body_mass_g ~ species + culmen_depth_mm,
  data = penguins
) |>
  write_output("mod_depth_spec", ver = version)
