# encoding: utf-8

User.delete_all
Status.delete_all

Weibo::WeiboService.fetch_from_github(false)

