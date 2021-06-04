# ================================================ [ setting ] ================================================
library(tidyverse); library(tidytext); library(RmecabKo); library(RcppMeCab)
library(ggraph); library(tidygraph)

data <- read_csv("/Users/gimjiseong/Downloads/kyungnam_news_total.csv")[, -1]

# ============================================ [ news summary ] ===============================================
data %>% 
  select(new_summary) %>%
  mutate(new_summary = as.character(new_summary),
         new_summary = str_remove_all(new_summary, "[:punct:]"),
         new_summary = str_remove_all(new_summary, "[\n|\\n]")) %>% 
  unnest_tokens(bigram, new_summary, token = token_ngrams, n = 2, div = "nouns") %>%
  separate(bigram, into = c("word1", "word2"), sep = " ") %>%
  filter(str_length(word1) > 1 & str_length(word2) > 1) %>%
  filter(!str_detect(word1, "[0-9]") & !str_detect(word2, "[0-9]")) %>%
  filter(!str_detect(word1, "[a-zA-Z]") & !str_detect(word2, "[a-zA-Z]")) %>%
  count(word1, word2, sort = T) %>% 
  filter(n > 7) -> bigram_graph

a <- grid::arrow(type = "closed", length = unit(.15, "inches"))
ggraph(bigram_graph, layout = "fr") +
  geom_edge_link(aes(edge_alpha = n), show.legend = FALSE, arrow = a, end_cap = circle(.07, 'inches')) +
  geom_node_point(color = "lightblue", size = 5) +
  geom_node_text(aes(label = name),  vjust = 1,  hjust = 1, family = "AppleGothic", size = 3) +
  theme_bw() + 
  xlab(" ") + 
  ylab(" ")

