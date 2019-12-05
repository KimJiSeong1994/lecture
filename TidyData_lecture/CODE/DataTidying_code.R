## ===================================================================

library(tidyverse); library(readxl)
setwd("C:/Users/knuser/Desktop")
data = read_xlsx("인구_가구_및_주택_읍면동(2017-2018).xlsx", col_names = F)  

## ===================================================================

names(data) <- data[2, ] # 변수 이름 변경
names(data) <- paste(data[1, ], names(data), sep = "_") 
data <- data[-c(1:2), ] # 변수이름으로 사용한 Obs 제거 

data %>% 
  filter(!`행정구역별(읍면동)_행정구역별(읍면동)` %in% c("전국","읍부", "면부", "동부"), # 필요없는 데이터 제거 
         str_detect(`행정구역별(읍면동)_행정구역별(읍면동)`, "시$")) %>% # 시 단위 데이터만 추출 
  gather(type, value, `2017_총인구 (명)`:`2018_주택이외의 거처 (호)`) %>%  
  separate(type, into = c("year", "type"), sep = "_") %>% 
  mutate(type = as.factor(type)) %>% 
  map_dfc(function(x) {
    if(str_detect(x[[1]], "[0-9]")) {
      as.numeric(x)
    } else{
      as.character(x)
    }
  }) %>% 
  group_split(type)

