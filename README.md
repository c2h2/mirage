Analysis youtube video page xpath, extract info and download tool.
=================================================================

* mirage.rb = crawl and analysis unprocessed youtube url

USAGE
=====

    ruby mirage.rb seed = seed an initial link to db (should run this first time)
    ruby mirage.rb run  = run the crawler
    ruby mirage.rb list = list all the counts (youtubes, links, pages)
    ruby mirage.rb extract = using youtube-dl to extract all the info
    ruby mirage.rb dl = using youtube-dl to dl videos

HOW
===
This is single threading crawling and downloading, this is easily expanded into multiple connections and distrubuited. by using e.g. (rabbitmq to communicate with master)

Disclaimer
==========
This is pure ruby expriemental, you should not use it for any commercial use. plz also read GPL file.
