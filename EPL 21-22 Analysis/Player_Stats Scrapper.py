#!/usr/bin/env python
# coding: utf-8

# Web Scraper to Download Player Stats Data

# In[3]:


from bs4 import BeautifulSoup
import requests
import openpyxl


# In[26]:


excel=openpyxl.Workbook()
sheet=excel.active
sheet.title='Liverpool'
sheet.append(['Player','Position','Age','Mp','Mins','Starts','Goals','Assists','Pen','Yc','Rc'])

url="https://fbref.com/en/squads/2abfe087/2021-2022/Watford-Stats"

ars_req = requests.get(url)

ars_data = BeautifulSoup(ars_req.text,'html.parser')

player = ars_data.find('tbody').find_all('tr')

for tr in player:
    player = tr.find('th').text
    age=tr.find_all('td',class_='center')[1].text
    mp=tr.find_all('td',class_="right")[0].text
    starts = tr.find_all('td',class_="right")[1].text
    mins = tr.find_all('td',class_="right")[2].text
    goals = tr.find_all('td',class_="right")[4].text
    assists = tr.find_all('td',class_="right")[5].text
    pen = tr.find_all('td',class_="right")[8].text
    yc= tr.find_all('td',class_="right")[10].text
    rc=tr.find_all('td',class_="right")[11].text
    pos = tr.find_all('td',class_='center')[0].text
    
    sheet.append([player,pos,age,mp,mins,starts,goals,assists,pen,yc,rc])
    
excel.save("D:\\Dharmesh\\SQL Notes\\SQL Projects\\EPL 21-22 Analysis\\teams\\Watford.xlsx")


# In[ ]:




