#!/usr/bin/env bash




readonly User_Agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/76.0.3809.100 Chrome/76.0.3809.100 Safari/537.36"




function RemoveLineBreaks() {
  echo "$1" | sed -z 's/\n/ /g'
}

function Trim() {
  echo "$1" | sed 's/^[ \t]*//;s/[ \t]*$//'
}




function DownloadPage() {
  curl --silent \
    -H 'Connection: keep-alive' \
    -H 'Cache-Control: max-age=0' \
    -H 'Upgrade-Insecure-Requests: 1' \
    -H "User-Agent: $User_Agent" \
    -H 'Sec-Fetch-Mode: navigate' \
    -H 'Sec-Fetch-User: ?1' \
    -H 'DNT: 1' \
    -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3' \
    -H 'Sec-Fetch-Site: none' \
    -H 'Accept-Language: en,en-US;q=0.9,ru;q=0.8,az;q=0.7' \
    "https://github.com/trending"
}




function GetTitle() {
  local title=$(echo "$1" | xmllint -xpath 'string((//article[@class="Box-row"])['$2']/h1/a)' -)
  title=$(RemoveLineBreaks "$title")
  title=$(Trim "$title")
  echo $title
}

function GetUsername() {
  local title=$(GetTitle "$1" "$2")
  local userName=$(echo "$title" | awk -F'/' '{ print $1 }')
  Trim "$userName"
}

function GetRepositoryName() {
  local title=$(GetTitle "$1" "$2")
  local repositoryName=$(echo "$title" | awk -F'/' '{ print $2 }')
  Trim "$repositoryName"
}

function GetLink() {
  local href=$(echo "$1" | xmllint -xpath 'string((//article[@class="Box-row"])['$2']/h1/a/attribute::href)' -)
  echo "https://github.com$href"
}

function GetProgrammingLanguage() {
  local lang=$(echo "$1" | xmllint -xpath 'string((//article[@class="Box-row"])['$2']//span[@itemprop="programmingLanguage"])' -)
  echo "$lang"
}

function GetDescription() {
  local desc=$(echo "$1" | xmllint -xpath 'string((//article[@class="Box-row"])['$2']/h1/following-sibling::p[1])' -)
  desc=$(RemoveLineBreaks "$desc")
  desc=$(Trim "$desc")
  echo "$desc"
}

function GetStars() {
  local stars=$(echo "$1" | xmllint -xpath '(//article[@class="Box-row"])['$2']//a[contains(@href, "stargazers")]/child::text()' -)
  stars=$(RemoveLineBreaks "$stars")
  stars=$(Trim "$stars")
  echo ${stars//,}
}




originPage=$(DownloadPage)
page=$(echo "$originPage" | xmllint --nowarning --recover - 2>/dev/null)
cnt=$(echo "$page" | xmllint -xpath 'count(//article[@class="Box-row"])' -)
for (( c=1; c<=$cnt; c++ )); do
  GetTitle "$page" "$c"
  GetUsername "$page" "$c"
  GetRepositoryName "$page" "$c"
  GetLink "$page" "$c"
  GetProgrammingLanguage "$page" "$c"
  GetDescription "$page" "$c"
  GetStars "$page" "$c"
  echo -e "\n\n"
done
