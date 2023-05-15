

# Functions -------------------------------------------------------
.please_install <- function(pkg) {
  if (
    !requireNamespace(pkg) &&
    askYesNo(
      paste0("It's OK to install the package ", pkg, "?"),
      default = FALSE
    )
  ) {
    install.packages(pkg)
  }

}




# Packages --------------------------------------------------------
.please_install("devtools")
.please_install("here")
.please_install("janitor")
.please_install("palmerpenguins")
.please_install("testthat")
.please_install("tidyverse")



# setup -----------------------------------------------------------
folders <- here::here(c("data-raw", "data", "output"))
purrr::walk(folders, dir.create)

file.path(folders, ".keep") |>
  purrr::walk(file.create)

palmerpenguins::penguins_raw |>
  readr::write_csv(here::here("data-raw/penguins.csv"))



# snapshot packages to renv ---------------------------------------

renv::snapshot()
