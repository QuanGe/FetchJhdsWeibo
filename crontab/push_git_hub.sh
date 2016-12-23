#!/usr/bin/env bash
export PATH=$PATH:/usr/local/bin
export TZ=Asia/Shanghai

echo "*********************************"
echo "*********************************"
date
echo "*********************************"
echo "*********************************"

cd /Users/Shared/GitHub/FetchJhdsWeibo
RAILS_ENV=production bundle exec rake weibo:export_to_quangelab

echo "*********************************"
echo "*********************************"
date
echo "*********************************"
echo "*********************************"