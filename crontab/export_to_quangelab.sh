#!/usr/bin/env bash

export PATH=$PATH:/usr/local/bin
export TZ=Asia/Shanghai

echo "*********************************"
echo "*********************************"
date
echo "*********************************"
echo "*********************************"

cd /Users/Shared/GitHub/FetchJhdsWeibo
source /Users/git/.rvm/environments/ruby-2.1.8
RAILS_ENV=development bundle exec rake weibo:export_to_quangelab

echo "*********************************"
echo "*********************************"
date
echo "*********************************"
echo "*********************************"