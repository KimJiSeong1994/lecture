# ================================================= [ setting ] ========================================================
import re
import time
import random
import pandas as pd
from tqdm import tqdm
from selenium import webdriver

drive_path = "/Users/gimjiseong/Downloads/selenium/" # chrome drive path
driver = webdriver.Chrome(drive_path + "chromedriver")
driver.get("https://everytime.kr/login") # 웹 주소로 이동

id_list = [ " ***** " ] # id 입력
ps_list = [" ***** "] # pw 입력 

input_ID = driver.find_element_by_xpath('//*[@id="container"]/form/p[1]/input')
input_ID.send_keys(id_list)
input_ps = driver.find_element_by_xpath('//*[@id="container"]/form/p[2]/input')
input_ps.send_keys(ps_list)
time.sleep(random.uniform(0, 1))

login = driver.find_element_by_css_selector('p.submit')
login.click()

# ============================================== [ Crawling ] ==========================================================
n = 1
total_df = pd.DataFrame(None)
while True:
    driver.get(f"https://everytime.kr/hotarticle/p/{n}")  # 핫게시판으로 이동
    time.sleep(random.uniform(1, 2))
    for p in [lnk.get_attribute("href") for lnk in driver.find_elements_by_css_selector("article > a.article")]:
        driver.get(p)
        time.sleep(random.uniform(2, 3))

        o_title = driver.find_element_by_css_selector('a.article > h2.large').text
        o_content = driver.find_element_by_xpath('//*[@id="container"]/div[2]/article/a/p').text
        total_df = total_df.append(pd.DataFrame({"title": o_title, "content": o_content}, index=[0]))

    driver.get(f"https://everytime.kr/hotarticle/p/{n}")
    time.sleep(random.uniform(1, 2))
    driver.find_element_by_class_name("next").click()  # 다음 페이지
    print("Complite Crawling : ", total_df.shape[0])
    n += 1
