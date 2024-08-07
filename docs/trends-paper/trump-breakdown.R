## Sorry for this inelegant plotting. I needed to make a graph for a paper - ALH

<<<<<<< HEAD
=======
library(googledrive)
>>>>>>> 7d41ffb (adding trump breakdown graph)
library(tidyverse)
library(ggplot2)

colors <- c("Sanctuary" = "blue2",
            "Immigration not Trump" = "orange2",
            "Trump not immigration" = "brown4",
            "Trump and immigration" = "red3")

df <- read_csv('Trump vs. Immigration - Sheet1.csv')
df |>
  mutate(start_date = as.Date(`start-date`)) |>
  filter(is_trump == 1 | is_immigration == 1,
         start_date >= '2016-11-01' & start_date <=  '2017-02-28') |>
  mutate(protest_type =
          case_when(is_sanctuary == 1 ~ 'Sanctuary',
                    is_immigration == 1 & is_trump == 0 & is_sanctuary == 0 ~ 'Immigration not Trump',
                    is_immigration == 0 & is_trump == 1 & is_sanctuary == 0 ~ 'Trump not immigration',
                    is_immigration == 1 & is_trump == 1 & is_sanctuary == 0 ~ 'Trump and immigration')) |>
  ggplot(aes(x=start_date, fill = protest_type)) +
    geom_bar() +
    labs(x = "Date", y = "Protest Count", title = "Third US Wave") +
    scale_y_continuous(expand = c(0, 0), limits = c(0,65), breaks = seq(0, 100, by = 10)) +
    scale_x_date(expand = c(0, 0),date_breaks = "3 days", date_labels = "%b %d") +
    theme_bw() +
    theme(
      axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 8),
      legend.title = element_blank()
    ) +
    scale_fill_manual(values = colors)
