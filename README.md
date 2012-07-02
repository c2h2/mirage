Crawling youtube video page, extract info and downloader.
==========================================================

Mirage is a process to crawl, search, extraction and downloader for youtube videos.

USAGE
=====
    ruby mirage.rb seed = seed an initial link to db (should run this first time)
    ruby mirage.rb run  = run the crawler
    ruby mirage.rb list = list all the counts (youtubes, links, pages)
    ruby mirage.rb extract = using youtube-dl to extract all the info
    ruby mirage.rb dl = using youtube-dl to dl videos

GET IT ROLLING
==============
first time:

    bundle install
    ruby mirage.rb seed
    edit conf/proxy.rb
    
Later, use 3 console to run:

    ruby mirage.rb run
    ruby mirage.rb dl
    cd sinatra && ruby app.rb

HOW
===
This is single thread crawling and downloader, this is easily expanded into multiple connections and distrubuited. by using e.g. (rabbitmq to communicate with master)

I have already made a distributed crawler, will merge into this later.

Disclaimer
==========
This is pure ruby expriemental, you should not use it for any commercial use. plz also read GPL file.
