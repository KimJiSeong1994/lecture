## —————————-------————— setting ————————-------------——————
library(tidyverse) ; library(rvest) ; library(RSelenium)

## ————————————————----------------------------————————————
# java -Dwevdriver.gec.ko.driver="geckodriver.exe" -jar selenium-server-standalone-3.141.59.jar -port 4445

remDR <- remoteDriver(remoteServerAddr = "localhost",
                      port = 4445L,
                      browserName = "chrome")

remDR$open()
remDR$navigate("https://search.daum.net/search?nil_suggest=btn&w=blog&DA=PGD&q=%EC%B0%BD%EC%9B%90%EC%8B%9C&page=1")

## —————————————————————————————

text_df = data.frame(NULL)
page = 1:50

for(i in page) {
  # navigate page ———————————
  remDR$navigate(paste0("https://search.daum.net/search?nil_suggest=btn&w=blog&DA=PGD&q=%EC%B0%BD%EC%9B%90%EC%8B%9C&page=", i))
  
  # page data gathering ———————————
  remDR$findElements(using = "class", value = "f_url") %>% 
    map(function(x) x$getElementText()) %>% 
    unlist() -> url_daum
  
  # blog data gathering ———————————
  for(k in 1:length(url_daum)) {
    if(!str_detect(url_daum[k], "blog.naver.com")) {
      remDR$navigate(paste0("https://",url_daum[k]))
      
      remDR$findElements(using = "css", value = "p") %>%
        map(function(x) x$getElementText()) %>%
        unlist() %>%
        .[str_detect(., "\\w")] -> text_vec 
      
      text_vec <- data.frame(text = text_vec)
      text_df <- rbind(text_df, text_vec)
      
      Sys.sleep(2)
    }
  }
}

write.csv(text_df, "text_df.csv")
