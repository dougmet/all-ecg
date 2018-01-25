library(rvest)
library(dplyr)

page <- read_html("https://www.physionet.org/physiobank/database")
lis <- page %>%
  html_nodes(xpath = "//h3[@id = 'ecg']/following-sibling::ul[1]") %>%
  html_nodes("li")

anchors <- html_node(lis, "a")  

stopifnot(length(anchors)==length(lis))


data.frame(Short = anchors %>% html_text(),
           Long = lis %>% html_text(),
           URL = anchors %>% html_attr("href"),
           stringsAsFactors = FALSE) %>%
  mutate(Description = stringr::str_replace_all(Long, "^\\[.*\\]", "")) %>%
  mutate(Tag =
           stringr::str_extract(Long, "^\\[.*\\]") %>%
           stringr::str_replace_all("\\[|\\]", "")) %>%
  mutate(Core = stringr::str_detect(Tag, "core"),
         ClassText =
           stringr::str_replace_all(Tag, "; core.*", "")) %>%
  mutate(Class =
           stringr::str_replace(ClassText, "Class |\\s", "") %>%
           as.integer()) %>%
  select(-Tag, -ClassText, -Long) %>%
  View()
