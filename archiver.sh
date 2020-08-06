
root_forum="australasia-pacific-pacific-islands-papua-new-guinea"
webpage="https://www.lonelyplanet.com/thorntree/forums/"
current_page=1
max_page=797

output_path="~/Desktop/thorntree-archive"
output_path=$( eval echo -n "~/Desktop/thorntree-archive" )


[ -d "$output_path" ] || {
	mkdir -p "$output_path"
}



function get_forum_posts_from_page() {

	curl -Ls "${webpage}${root_forum}?page=${1}" | grep -o 'href="[^"]*"' | grep -v '[#?:]' | sed -n -e "s/^.*href=\"\/thorntree\/forums\/$root_forum\///p" | sed 's/"//g' | grep -v '^topics/new$'
}

for page in $(seq $current_page $max_page); do
	for forum in $( get_forum_posts_from_page $page ); do
		sub_forum=$( echo $forum | cut -d'/' -f1 )
		page_name=$( echo $forum | cut -d'/' -f2 )
		req_page="${webpage}${root_forum}/topics/${page_name}/compact?"


		curl -Is $req_page | head -n1 | grep -q '200'
		[ $? -eq 0 ] || {
			continue
		}

		page_HTML=$( curl -Ls $req_page )
		page_date=$( echo $page_HTML | grep -E -o '<small class="timeago">([0-9]+ [a-zA-Z]+ [0-9]+)</small>' | sed -E 's/<small class="timeago">([0-9]+ [a-zA-Z]+ [0-9]+)<\/small>/\1/g' | tail -n1 )

		[ -d "${output_path}/${sub_forum}" ] || {
			mkdir -p "${output_path}/${sub_forum}"
		}


		echo "$page_HTML" > "${output_path}/${sub_forum}/${page_name}.html"
		touch -d "$page_date" "${output_path}/${sub_forum}/${page_name}.html"

	done
done
