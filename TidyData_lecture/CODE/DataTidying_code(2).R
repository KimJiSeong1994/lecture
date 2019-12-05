## ================================================================

library(tidyverse); library(readxl)
setwd("C:/Users/knuser/Desktop")
data = read_xlsx("인구_가구_및_주택_읍면동(2017-2018).xlsx", col_names = F)  
data2 <- read_xlsx("성취에_대한_만족도__19세_이상_인구__20191204135305.xlsx", col_names = F)


## ===================================================================

names(data2) <- data2[1, ]
names(data2) <- paste(names(data2), data2[2, ], sep = "_")
data2 <- data2[-c(1:2), ]

data2 %>% 
  fill(`행정구역별(1)_행정구역별(1)`, `특성별(1)_특성별(1)`) %>% 
  gather(type, value, `2019_계` : `2019_매우 불만족`) %>%
  separate(type, into = c("year", "tage"), sep = "_") %>% 
  filter(tage != "계" & `특성별(1)_특성별(1)` != "전체" & `특성별(1)_특성별(1)` != "동·읍면부") %>% 
  map_dfc(function(x) {
    if(str_detect(x[[1]], "[0-9]")) {
      as.numeric(x)
    } else {
      as.character(x)
    }
  }) %>%
  group_split(`특성별(1)_특성별(1)`)
