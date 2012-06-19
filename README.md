Analysis youtube video page xpath.

* seed_link.rb = feed a first link to db, this should be run at the first time to seed the first link.
* mirage.rb = crawl and analysis unprocessed youtube url
* list_link.rb, list_youtube.rb = listing all the link and youtube video data records.
* info_extractor.rb = find all youtube video information (uploader, title, thumbnail url) for all unprocessed links
* downloader.rb = download all unsaved youtube video into localdir.

this is single threading crawling and downloading, this is easily expanded into multiple connections and distrubuited. by using e.g. (rabbitmq to communicate with master)

Disclaimer: this is pure ruby expriemental, you should not use it for any commercial use. plz also read GPL file.
