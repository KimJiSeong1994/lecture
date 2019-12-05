library(tidyverse) ; library(rvest) ; library(RSelenium)

##
remDR <- remoteDriver(remoteServerAddr = "localhost",
                      port = 4445L,
                      browserName = "chrome")

remDR$open()
remDR$navigate("https://www.youtube.com/results?search_query=%EC%A7%84%EC%A7%9C%EC%9D%B4%EC%9C%A0&sp=CAISBAgFEAE%253D")

### loop 
Youtube_data <- data.frame(title = NULL,
                           view_num = NULL,
                           recent = NULL)

n = 1 
while (TRUE) {
    if(n < 100) {
    for(n in 1:1000) {
      title <- remDR$findElements(using = "id", value = "video-title")
      title %>% 
        map(function(x) x$getElementText()) %>% 
        unlist() -> title_list # video title
      
      view_number <- remDR$findElements(using = "xpath", value = "//*[@id='metadata-line']/span[1]")
      view_number %>% 
        map(function(x) x$getElementText()) %>% 
        unlist() -> view_number_list # view numbe
      
      befor_days <- remDR$findElements(using = "xpath", value = "//*[@id='metadata-line']/span[2]")
      befor_days %>% 
        map(function(x) x$getElementText()) %>% 
        unlist() -> befor_days_list # recent
      
      webElem <- remDR$findElement("css", "body")
      webElem$sendKeysToElement(list(key = "end")) # scrol down
      
      data <- data.frame(title = title_list, 
                         view_num = view_number_list,
                         recent = befor_days_list)
      Youtube_data <- rbind(Youtube_data, data)  # total data
      Sys.sleep(1) # system sleep 
      
      n = n + 1 # n * scoll-down
    }
  }
  else {
    break()
  }
}

write.csv(Youtube_data, "Youtube_data.csv") 

